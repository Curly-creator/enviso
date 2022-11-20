import 'package:enviso/services/transportdata.dart';
import 'package:flutter/material.dart';
import 'package:enviso/services/transportapi.dart';

class DataSite extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Data'),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage), 
              onPressed: () {
              
            },)
          ],
        ),
        body: FutureBuilder<List<TransportData>>(
            future: TransportApi.getData(context),
            builder: (context, snapshot) {
              final transportData = snapshot.data;
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return const Center(child: Text('Some error occurred!'));
                  } else {
                    return buildTransportData(transportData!);
                  }
              }
            }),
      );

  Widget buildTransportData(List<TransportData> transportData) =>
      ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: transportData.length,
        itemBuilder: (context, index) {
          final transport = transportData[index];
          return ListTile(
            title: Text('vehicle:' +
                transport.vehicle +
                " distance: " +
                transport.distance.toString()),
          );
        },
      );
}
