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

  const co2test = await fetchclimatiq(activity_id, distance);

  return database.collection('user').doc(userid).collection('transport').doc(transportid).update({ co2e: co2test });
})

exports.onTransportUpdate = functions.firestore.document('user/{userid}/transport/{transportid}').onUpdate(async (change, context) => {
  const userid = context.params.userid;
  const transportid = context.params.transportid;
  if (change.before.get('co2e') === change.after.get('co2e')) return null;

  const newValue = change.after.get('co2e');
  const oldValue = change.before.get('co2');
  const addValue = newValue - oldValue;

  const calc = database.collection('user').doc(userid).collection('transport').doc('_calculations');

  return await calc.update({ car: admin.firestore.FieldValue.increment(addValue) });
})


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

