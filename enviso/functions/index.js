const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch')

admin.initializeApp();

const database = admin.firestore();
const app = express();

exports.onUserCreate = functions.firestore.document('user/{userid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  await database.collection('user').doc(userid).collection('transport').doc('_calculations').set({
    car: 0,
    air: 0,
    sub: 0,
    train: 0,
    bus: 0,
    total: 0,
  })
  return await database.collection('user').doc(userid).collection('transport').add({
    vehicle: 'car',
    distance: 250,
    co2e: null
  })
})

exports.onTransportCreate = functions.firestore.document('user/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  if (context.params.transportid === '_calculations') return null;
  const distance = snap.get('distance');
  const vehicle = snap.get('vehicle');

  const userid = context.params.userid;
  const transportid = context.params.transportid;

  const activity_id = setActivityId(vehicle);

  const climatiqCo2e = await fetchclimatiq(activity_id, distance);

  return database.collection('user').doc(userid).collection('transport').doc(transportid).update({ co2e: climatiqCo2e });
})

exports.onTransportUpdate = functions.firestore.document('user/{userid}/transport/{transportid}').onUpdate(async (change, context) => {
  if (change.before.get('co2e') === change.after.get('co2e')) return null;
  const userid = context.params.userid;

  const newValue = await change.after.get('co2e');
  const oldValue = await change.before.get('co2e');
  const vehicle = await change.after.get('vehicle');
  const addValue = newValue - oldValue;

  const calc = database.collection('user').doc(userid).collection('transport').doc('_calculations');

  switch (vehicle) {
    case 'car':
      return await calc.update({ car: admin.firestore.FieldValue.increment(addValue) });
    case 'train':
      return await calc.update({ train: admin.firestore.FieldValue.increment(addValue) });
    case 'bus':
      return await calc.update({ bus: admin.firestore.FieldValue.increment(addValue) });
    case 'sub':
      return await calc.update({ sub: admin.firestore.FieldValue.increment(addValue) });
    case 'air':
      return await calc.update({ air: admin.firestore.FieldValue.increment(addValue) });
  }
})

exports.onCalculationUpdate = functions.firestore.document('user/{userid}/transport/_calculations').onUpdate(async (change, context) => {
  if (change.before.get('total') !== change.after.get('total')) return null;
  const userid = context.params.userid;
  const calc = database.collection('user').doc(userid).collection('transport').doc('_calculations');
  const doc = await calc.get();

  console.log('Doc: ', doc.data());
  const addValue = await calcValue(change, doc);

  console.log('addValoutside: ', addValue);
  return await calc.update({ total: admin.firestore.FieldValue.increment(addValue) });
})

exports.onTransportDelete = functions.firestore.document('user/{userid}/transport/{transportid}').onDelete(async (snap, context) => {
  const userid = context.params.userid;
  const calc = database.collection('user').doc(userid).collection('transport').doc('_calculations');

  const delValue = await snap.get('co2e');

  return await calc.update({ car: admin.firestore.FieldValue.increment(0 - delValue) });
})

const calcValue = async (change, doc) => {
  vehicles = ['car', 'air', 'bus', 'sub', 'train'];
  let addValue = 0;
  for await (vehicle of vehicles) {
    console.log('element: ', vehicle);
    let oldValue = await change.before.get(vehicle);
    let newValue = await change.after.get(vehicle);
    if (oldValue != newValue) {
      addValue += newValue - oldValue;
      console.log('addVal inside: ', addValue);
    }
  }
  return addValue;
}


const fetchclimatiq = async (activity_id, distance) => {
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
        "lca_activity": "upstream-fuel_combustion"
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

function setActivityId(vehicle) {
  switch (vehicle) {
    case "car":
      return "passenger_vehicle-vehicle_type_car-fuel_source_diesel-distance_na-engine_size_medium"
    case "air":
      return "passenger_flight-route_type_domestic-aircraft_type_na-distance_na-class_na-rf_na"
    case "train":
      return "passenger_train-route_type_long_distance-fuel_source_diesel"
    case "sub":
      return "passenger_train-route_type_local-fuel_source_diesel"
    case "bus":
      return "passenger_vehicle-vehicle_type_bus_line-fuel_source_diesel-distance_na-engine_size_na"
    default:
      return null
  }
}

