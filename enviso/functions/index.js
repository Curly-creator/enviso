const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch')

admin.initializeApp();

const database = admin.firestore();
const app = express();

exports.onUserCreate = functions.firestore.document('users/{userid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  return await database.collection('users').doc(userid).collection('transport').doc('.calculations').set({
    IN_PASSENGER_VEHICLE: 0,
    FLYING: 0,
    IN_SUBWAY: 0,
    IN_TRAIN: 0,
    IN_TRAM: 0,
    IN_BUS: 0,
    TOTAL: 0,
  })
})

exports.onTransportCreate = functions.firestore.document('users/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  if (context.params.transportid === '.calculations') return null;
  const distance = snap.get('distance');
  const vehicle = snap.get('vehicle');
  const userid = context.params.userid;
  const transportid = context.params.transportid;
  const userSnapshot = await database.collection('users').doc(userid).get();
  const engineSize = userSnapshot.get('engine_size');
  const fuelType = userSnapshot.get('fuel_type');

  const climatiqCo2e = await fetchclimatiq(vehicle, engineSize, fuelType, distance);

  return database.collection('users').doc(userid).collection('transport').doc(transportid).update({ co2e: climatiqCo2e });
})

exports.onTransportUpdate = functions.firestore.document('users/{userid}/transport/{transportid}').onUpdate(async (change, context) => {
  if (change.before.get('co2e') === change.after.get('co2e')) return null;
  const userid = context.params.userid;

  const newValue = await change.after.get('co2e');
  const oldValue = await change.before.get('co2e');
  const vehicle = await change.after.get('vehicle');
  const addValue = newValue - oldValue;

  const calc = database.collection('users').doc(userid).collection('transport').doc('.calculations');

  switch (vehicle) {
    case 'IN_PASSENGER_VEHICLE':
      return await calc.update({ IN_PASSENGER_VEHICLE: admin.firestore.FieldValue.increment(addValue) });
    case 'IN_TRAIN':
      return await calc.update({ IN_TRAIN: admin.firestore.FieldValue.increment(addValue) });
    case 'IN_BUS':
      return await calc.update({ IN_BUS: admin.firestore.FieldValue.increment(addValue) });
    case 'IN_SUBWAY':
      return await calc.update({ IN_SUBWAY: admin.firestore.FieldValue.increment(addValue) });
    case 'IN_TRAM':
      return await calc.update({ FLYING: admin.firestore.FieldValue.increment(addValue) });
    case 'FLYING':
      return await calc.update({ IN_TRAM: admin.firestore.FieldValue.increment(addValue) });
  }
})

exports.onCalculationUpdate = functions.firestore.document('users/{userid}/transport/.calculations').onUpdate(async (change, context) => {
  if (change.before.get('TOTAL') !== change.after.get('TOTAL')) return null;
  const userid = context.params.userid;
  const calc = database.collection('users').doc(userid).collection('transport').doc('.calculations');
  const doc = await calc.get();
  const addValue = await calcValue(change, doc);

  return await calc.update({ TOTAL: admin.firestore.FieldValue.increment(addValue) });
})

exports.onTransportDelete = functions.firestore.document('users/{userid}/transport/{transportid}').onDelete(async (snap, context) => {
  const userid = context.params.userid;
  const calc = database.collection('users').doc(userid).collection('transport').doc('.calculations');
  const vehicle = await snap.get('vehicle');
  const delValue = await snap.get('co2e');

  switch (vehicle) {
    case 'IN_PASSENGER_VEHICLE':
      return await calc.update({ IN_PASSENGER_VEHICLE: admin.firestore.FieldValue.increment(0 - delValue) });
    case 'IN_TRAIN':
      return await calc.update({ IN_TRAIN: admin.firestore.FieldValue.increment(0 - delValue) });
    case 'IN_BUS':
      return await calc.update({ IN_BUS: admin.firestore.FieldValue.increment(0 - delValue) });
    case 'IN_SUBWAY':
      return await calc.update({ IN_SUBWAY: admin.firestore.FieldValue.increment(0 - delValue) });
    case 'IN_TRAM':
      return await calc.update({ FLYING: admin.firestore.FieldValue.increment(0 - delValue) });
    case 'FLYING':
      return await calc.update({ IN_TRAM: admin.firestore.FieldValue.increment(0 - delValue) });
  }
})

const calcValue = async (change, doc) => {
  vehicles = ['IN_PASSENGER_VEHICLE', 'FLYING', 'IN_BUS', 'IN_SUBWAY', 'IN_TRAIN', 'IN_TRAM'];
  let addValue = 0;
  for await (vehicle of vehicles) {
    let oldValue = await change.before.get(vehicle);
    let newValue = await change.after.get(vehicle);
    if (oldValue != newValue) {
      addValue += newValue - oldValue;
    }
  }
  return addValue;
}

const fetchclimatiq = async (vehicle, engineSize, fuelType, distance) => {

  const lca_activity = setLcaActivity(vehicle, fuelType);
  const activity_id = setActivityId(vehicle, engineSize, fuelType);

  const response = await fetch('https://beta3.api.climatiq.io/estimate', {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + "6PSXPVTWR245D5J9S7HCM42J7ZVM",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      "emission_factor": {
        "activity_id": activity_id,
        "source": "UBA",
        "region": "DE",
        "year": "2020",
        "lca_activity": lca_activity
      },
      "parameters": {
        "passengers": 1,
        "distance": distance,
        "distance_unit": "km"
      }
    })
  });
  if (!response.ok) { throw response };
  const data = await response.json();
  return data.co2e;
}

function setLcaActivity(vehicle, fuelType) {
  if (vehicle == "IN_PASSENGER_VEHICLE" && fuelType == "petrol") { return "fuel_combustion"; }
  if (vehicle == "IN_PASSENGER_VEHICLE" && fuelType == "bev") { return "upstream-electricity_consumption" }
  return "upstream-fuel_combustion";
}

function setActivityId(vehicle, engineSize, fuelType) {
  if (fuelType == "bev") { engineSize = 'na' }

  if (engineSize == 'medium' && fuelType == "fcew") { engineSize = 'na' }

  switch (vehicle) {
    case "IN_PASSENGER_VEHICLE":
      return "passenger_vehicle-vehicle_type_car-fuel_source_" + fuelType + "-distance_na-engine_size_" + engineSize
    case "FLYING":
      return "passenger_flight-route_type_domestic-aircraft_type_na-distance_na-class_na-rf_na"
    case "IN_TRAIN":
      return "passenger_train-route_type_long_distance-fuel_source_diesel"
    case "IN_SUBWAY":
      return "passenger_train-route_type_local-fuel_source_diesel"
    case "IN_TRAM":
      return "passenger_train-route_type_local-fuel_source_diesel"
    case "IN_BUS":
      return "passenger_vehicle-vehicle_type_bus-fuel_source_na-distance_na-engine_size_na"
    default:
      return null
  }
}

