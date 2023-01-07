const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch')

admin.initializeApp();

const database = admin.firestore();
const app = express();

var vehicles= ["IN_PASSENGER_VEHICLE", "IN_BUS", "IN_SUBWAY", "IN_TRAM", "FLYING", "IN_TRAIN"]


exports.onUserCreate = functions.firestore.document('users/{userid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  return await database.collection('users').doc(userid).collection('calculation').doc('TOTAL').set({
    IN_PASSENGER_VEHICLE: 0,
    FLYING: 0,
    IN_SUBWAY: 0,
    IN_TRAIN: 0,
    IN_TRAM: 0,
    IN_BUS: 0,
    TOTAL: 0,
  }); 
})

exports.onTokenCreate = functions.firestore.document('users/{userid}').onUpdate(async (change, context) => {
  if(change.before.get('access_token') == change.after.get('access_token')) return null;

  const userid = context.params.userid;
  
  const accessToken = context.params.access_token;

  const day = new Date().getDate().toString();
  const month = new Date().getMonth().toString() + 1;
  const year = new Date().getFullYear().toString();
  const endDate = year + '-' + month + '-' + day;
  const startDate = '2020-01-01';
  
  const data = {
    'access_token':accessToken,
    'client_id':'635fb7749f143e0013c8b0b0',
    'secret':'4677ec60b05fb453e0b629a6f0df50',
    'start_date':startDate,
    'end_date':endDate
  }
  const url = "https://sandbox.plaid.com/transactions/get";
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
  const plaid_data = await response.json();
  // test

  database.collection('users').doc(userid).collection('plaid').add({
    'total_transactions':'test'
  });
  // response
  console.log(plaid_data);
  plaid_data.transactions.forEach(async transaction => {
    if (transaction.category[0] == "Food and Drink") {
        // call climatiq food and drink
      var co2e = fetchclimatiqPlaid_Food(transaction.amount);
      var date = transaction.date;
      var category = transaction.category[0]
      await database.collection('users').doc(userid).collection('plaid').add({
       'Category' : category,
       'co2e' : co2e,
       'date' : date
     })
    }
  });   
  return null;
})

const fetchclimatiqPlaid_Food = async (amount) => {
  
  var amount = amount * 1.07; //aktueller €/USD Kurs
  const response = await fetch('https://beta3.api.climatiq.io/estimate', {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + "6PSXPVTWR245D5J9S7HCM42J7ZVM",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      "emission_factor": {
        "activity_id": "consumer_goods-type_food_beverages_tobacco",
        "source": "GHG Protocol",
        "region": "GLOBAL",
        "year": "2017",
        "lca_activity": "unknown"
      },
      "parameters": {
        "money": amount,
        "money_unit": "usd"
      }
    })
  });

  if (!response.ok) { throw response };
  const data = await response.json();
  return data.co2e;
}

exports.onTransportCreate = functions.firestore.document('users/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  if (context.params.transportid === null) return null;
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

exports.onYearCreate = functions.firestore.document('users/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  const year = snap.get('timestamp').toDate().getFullYear().toString();
  const month = snap.get('timestamp').toDate().getMonth().toString();
  const test = database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc(month).get().then((snap) =>{
    if(snap.exists) return null;
    else{
      return database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc(month).set({
        IN_PASSENGER_VEHICLE: 0,
        FLYING: 0,
        IN_SUBWAY: 0,
        IN_TRAIN: 0,
        IN_TRAM: 0,
        IN_BUS: 0,
        TOTAL: 0,
      }); 
    }
  });
})

exports.onTransportYearCreate = functions.firestore.document('users/{userid}/calculation/{year}/transport/{month}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  const year = context.params.year;

  return await database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc('TOTAL').set({
    IN_PASSENGER_VEHICLE: 0,
    FLYING: 0,
    IN_SUBWAY: 0,
    IN_TRAIN: 0,
    IN_TRAM: 0,
    IN_BUS: 0,
    TOTAL: 0,
  }); 
})

exports.onYearToAllUpdate = functions.firestore.document('users/{userid}/calculation/{year}').onUpdate(async (change,context) => {
  if(context.params.year == "TOTAL") return null;
  const userid = context.params.userid;
  const year = context.params.year;

  const calc = database.collection('users').doc(userid).collection('calculation').doc('TOTAL');
  var object = {};

  vehicles.forEach(async vehicle => {
    if (change.before.get(vehicle) != change.after.get(vehicle))
    {   
        const value = change.after.get(vehicle);
        object[vehicle] = admin.firestore.FieldValue.increment(value);      
        return await calc.update(object)
    };
  });
})

exports.onMonthToYearUpdate = functions.firestore.document('users/{userid}/calculation/{year}/transport/{month}').onUpdate(async (change,context) => {
  if(context.params.month == "TOTAL") return null;
  const userid = context.params.userid;
  const year = context.params.year;

  const calc = database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc('TOTAL');
  var object = {};

  vehicles.forEach(async vehicle => {
    if (change.before.get(vehicle) != change.after.get(vehicle))
    {   
        const value = change.after.get(vehicle);
        object[vehicle] = admin.firestore.FieldValue.increment(value);      
        return await calc.update(object)
    };
  });
})

exports.onTransportUpdate = functions.firestore.document('users/{userid}/transport/{transportid}').onUpdate(async (change, context) => {
  if (change.before.get('co2e') === change.after.get('co2e')) return null;
  const userid = context.params.userid;
  const year = await change.after.get('timestamp').toDate().getFullYear().toString();
  const month = await change.after.get('timestamp').toDate().getMonth().toString();

  const newValue = await change.after.get('co2e');
  const oldValue = await change.before.get('co2e');
  const vehicle = await change.after.get('vehicle');
  const addValue = newValue - oldValue;
  const calc = database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc(month);
  
  var object = {};
  object[vehicle] = admin.firestore.FieldValue.increment(addValue);  
  return await calc.update(object)
})

exports.onMonthCalculationUpdate = functions.firestore.document('users/{userid}/calculation/{year}/transport/{month}').onUpdate(async (change, context) => {
  if (change.before.get('TOTAL') !== change.after.get('TOTAL')) return null;
  const userid = context.params.userid;
  const year = context.params.year;
  const month = context.params.month;
  const calc = database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc(month);
  const doc = await calc.get();
  const addValue = await calcValue(change, doc);

  return await calc.update({ TOTAL: admin.firestore.FieldValue.increment(addValue) });
})

exports.onTransportDelete = functions.firestore.document('users/{userid}/transport/{transportid}').onDelete(async (snap, context) => {
  const userid = context.params.userid;
  const calc = database.collection('users').doc(userid).collection('transport').doc('.calculations');
  const vehicle = await snap.get('vehicle');
  const delValue = await snap.get('co2e');

  var object = {};
  object[vehicle] = admin.firestore.FieldValue.increment(0 - delValue);  
  return await calc.update(object)
})


const calcValue = async (change, doc) => {
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
  if (fuelType == "bev") { engineSize = "na" }
  if (engineSize == "small" && fuelType == "petrol") { fuelType = "bio_petrol" }
  if (engineSize == "medium" && fuelType == "petrol") { fuelType = "bio_petrol" }
  if (engineSize == "medium" && fuelType == "fcev") { engineSize = "na" }

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



