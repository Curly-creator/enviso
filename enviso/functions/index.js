const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch')

admin.initializeApp();

const database = admin.firestore();
const app = express();

var distance;
var vehicle;
var co2e;
var activity_id;

exports.onUserCreate = functions.firestore.document('user/{userid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  await database.collection('user').doc(userid).collection('transport').doc('_calculations').set({
    car: 0,
    air: 0,
    sub: 0,
    train: 0,
    bus: 0
  })
  return await database.collection('user').doc(userid).collection('transport').add({
    vehicle: 'car',
    distance: 500,
    co2e: null
  })
})

exports.onTransportCreate = functions.firestore.document('user/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  if (context.params.transportid === '_calculations') return null;
  if (snap.get('distance') != null && snap.get('distance') != null) {
    distance = snap.get('distance');
    vehicle = snap.get('vehicle');
  }
  else return null;

  const userid = context.params.userid;
  const transportid = context.params.transportid;
  activity_id = setActivityId(vehicle);
  functions.logger.log('activity_id: ', activity_id);
  await fetchclimatiq();

  return await database.collection('user').doc(userid).collection('transport').doc(transportid).update({ co2e: co2e })

})

exports.onTransportUpdate = functions.firestore.document('user/{userid}/transport/{transportid}').onUpdate(async (change, context) => {
  const userid = context.params.userid;
  const transportid = context.params.transportid;
  if (change.before.get('co2e') === change.after.get('co2e')) return null;

  const new_co2e = change.after.get('co2e');
  const calc = database.collection('user').doc(userid).collection('transport').doc('_calculations');

  return await calc.update({ car: admin.firestore.FieldValue.increment(1) });
})


const fetchclimatiq = async () => {
  fetch('https://beta3.api.climatiq.io/estimate', {
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
  })
    .then((res) => {
      if (!res.ok) { throw res }
      return res.json();
    })
    .then(data => {
      co2e = data.co2e;
      return null;
    })
    .catch(e => {
      e.text().then(errorMessage => functions.logger.log('Error: ', errorMessage))
    });
}

function setActivityId(vehicle) {
  switch (vehicle) {
    case "car":
      return "passenger_vehicle-vehicle_type_car-fuel_source_bio_petrol-distance_na-engine_size_medium"
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

