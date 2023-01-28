const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();

const database = admin.firestore();

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
    var co2e = await fetchclimatiqPlaid_Food(transaction.amount);
    var timestamp = new Date(transaction.date);
    var category = transaction.category[0];
    database.collection('users').doc(userid).collection('consum').add({
      category : category,
      co2e : co2e,
      timestamp : timestamp
    })
  return null;
})})

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

  const climatiqCo2e = await fetchclimatiqTransport(vehicle, engineSize, fuelType, distance);

  return database.collection('users').doc(userid).collection('transport').doc(transportid).update({ co2e: climatiqCo2e });
})

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