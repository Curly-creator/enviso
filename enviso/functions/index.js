const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');
//const moment = require('moment');

admin.initializeApp();

const database = admin.firestore();
const app = express();

var vehicles= ["IN_PASSENGER_VEHICLE", "IN_BUS", "IN_SUBWAY", "IN_TRAM", "FLYING", "IN_TRAIN"];
var plaidCata = ["Food and Drinks"]


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

exports.onTokenUpdate = functions.firestore.document('users/{userid}').onUpdate(async (change, context) => {
  if(change.before.get('access_token') == change.after.get('access_token')) return null;

  const userid = context.params.userid;
  
  const accessToken = await change.after.get('access_token');
  
  const startDate = '2020-01-01';
  const endDate = '2023-01-01';
  
  const data = {
    'access_token': accessToken,
    'client_id':'635fb7749f143e0013c8b0b0',
    'secret':'4677ec60b05fb453e0b629a6f0df50',
    'start_date': startDate,
    'end_date': endDate
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

  plaid_data.transactions.forEach(async transaction => {
    if (transaction.category[0] == "Food and Drink") {
      var co2e = await fetchclimatiqPlaid_Food(transaction.amount);
      console.log('AMOUNT: ', transaction.amount)
      var timestamp = new Date(transaction.date).getTime()/ 1000;
      var category = transaction.category[0]
      console.log('TIMESTAMP: ', timestamp);
      await database.collection('users').doc(userid).collection('consum').add({
       category : category,
       co2e : co2e,
       timestamp : timestamp
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
  console.log('CLIMATIQSTUFF: ', response)
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

  const climatiqCo2e = await fetchclimatiqTransport(vehicle, engineSize, fuelType, distance);

  return database.collection('users').doc(userid).collection('transport').doc(transportid).update({ co2e: climatiqCo2e });
})

exports.onYearCreate = functions.firestore.document('users/{userid}/transport/{transportid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  const year = snap.get('timestamp').toDate().getFullYear().toString();
  const month = snap.get('timestamp').toDate().getMonth().toString();
  database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc(month).get().then((snap) =>{
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

exports.onYearCreateConsum = functions.firestore.document('user/{userid}/consum/{consumid}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  const year = snap.get('timestamp').toDate().getFullYear().toString();
  const month = snap.get('timestamp').toDate().getMonth().toString();
  database.collection('users').doc(userid).collection('calculation').doc(year).collection('consum').doc(month).get().then((snap) =>{
    if(snap.exists) return null;
    else{
      return database.collection('users').doc(userid).collection('calculation').doc(year).collection('consum').doc(month).set({
        FOOD_DRINKS: 0,
        TOTAL: 0,
      }); 
    }
  });
})

exports.oncategoryYearCreate = functions.firestore.document('users/{userid}/calculation/{year}/{category}/{month}').onCreate(async (snap, context) => {
  const userid = context.params.userid;
  const year = context.params.year;
  const category = context.params.category;
  database.collection('users').doc(userid).collection('calculation').doc(year).collection(category).doc('yearTotal').get().then(async (snap) =>{
    if(snap.exists) return null;
    else{
      if(category == 'transport'){
        return await database.collection('users').doc(userid).collection('calculation').doc(year).collection('transport').doc('yearTotal').set({
          IN_PASSENGER_VEHICLE: 0,
          FLYING: 0,
          IN_SUBWAY: 0,
          IN_TRAIN: 0,
          IN_TRAM: 0,
          IN_BUS: 0,
          TOTAL: 0,
        }); 
      }
      else{
        return await database.collection('users').doc(userid).collection('calculation').doc(year).collection('consum').doc('yearTotal').set({
          FOOD_DRINKS: 0,
          TOTAL: 0,
        }); 
      }
    }
  })
})

exports.onYearToAllUpdate = functions.firestore.document('users/{userid}/calculation/{year}/{category}/{month}').onUpdate(async (change,context) => {
  if(context.params.year == "TOTAL") return null;
  const userid = context.params.userid;
  const category = context.params.category;
  
  const calc = database.collection('users').doc(userid).collection('calculation').doc('TOTAL');
  
  var object = {};
  var array = [];

  if(category == 'transport'){
    array = vehicles;
  }
  else{
    array = plaidCata;
  }

  array.forEach(async element => {
    if (change.before.get(element) != change.after.get(element))
    {   
        const value = change.after.get(element);
        object[element] = admin.firestore.FieldValue.increment(value);      
        return await calc.update(object);
    };
  });
})

exports.onMonthToYearUpdate = functions.firestore.document('users/{userid}/calculation/{year}/{category}/{month}').onUpdate(async (change,context) => {
  if(context.params.month == "yearTotal") return null;
  const userid = context.params.userid;
  const year = context.params.year;
  const category = context.params.category;

  const calc = database.collection('users').doc(userid).collection('calculation').doc(year).collection(category).doc('yearTotal');

  var object = {};
  var array = [];

  if(category == 'transport'){
    array = vehicles;
  }
  else{
    array = plaidCata;
  }

  array.forEach(async element => {
    if (await change.before.get(element) != await change.after.get(element))
    {   
        const value = change.after.get(element);
        object[element] = admin.firestore.FieldValue.increment(value);      
        return await calc.update(object);
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

exports.onMonthCalculationUpdate = functions.firestore.document('users/{userid}/calculation/{year}/{category}/{month}').onUpdate(async (change, context) => {
  if (change.before.get('TOTAL') !== change.after.get('TOTAL')) return null;
  const userid = context.params.userid;
  const year = context.params.year;
  const month = context.params.month;
  const category = context.params.category;
  const calc = database.collection('users').doc(userid).collection('calculation').doc(year).collection(category).doc(month);

  const addValue = await calculationDiff(change);
  return await calc.update({ TOTAL: admin.firestore.FieldValue.increment(addValue)});

})

exports.onAllCalculationUpdate = functions.firestore.document('users/{userid}/calculation/{year}').onUpdate(async (change, context) => {
  //if (change.before.get('TOTAL') === change.after.get('TOTAL')) return null;
  if (context.params.year == 'TOTAL') return null;
  const userid = context.params.userid;

  const calc = database.collection('users').doc(userid).collection('calculation').doc('TOTAL');
  const addValue = await calculationDiff(change);
  return await calc.update({ TOTAL: admin.firestore.FieldValue.increment(addValue)});
})

//umschreiben nötig
exports.onTransportDelete = functions.firestore.document('users/{userid}/transport/{transportid}').onDelete(async (snap, context) => {
  const userid = context.params.userid;
  const calc = database.collection('users').doc(userid).collection('transport').doc('.calculations');
  const vehicle = await snap.get('vehicle');
  const delValue = await snap.get('co2e');

  var object = {};
  object[vehicle] = admin.firestore.FieldValue.increment(0 - delValue);  
  return await calc.update(object);
})

const calculationDiff = async (change) => {
  let addValue = 0;
  vehicles.forEach(async vehicle => {
    let oldValue = await change.before.get(vehicle);
    let newValue = await change.after.get(vehicle);
    if (oldValue != newValue) {
      addValue += newValue - oldValue;
    }
  })
  return addValue;
}

const fetchclimatiqTransport = async (vehicle, engineSize, fuelType, distance) => {

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