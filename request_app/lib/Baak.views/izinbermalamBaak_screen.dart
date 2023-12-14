import 'package:flutter/material.dart';
import 'package:it_del/Models/api_response.dart';
import 'package:it_del/Models/izinbermalamBaak.dart';
import 'package:it_del/Services/izinbermalamBaak_service.dart';

class IzinBermalamBaakView extends StatefulWidget {
  @override
  _IzinBermalamBaakViewState createState() => _IzinBermalamBaakViewState();
}

class _IzinBermalamBaakViewState extends State<IzinBermalamBaakView> {
  late Future<ApiResponse<List<IzinBermalamBaak>>> _izinBermalamData;

  @override
  void initState() {
    super.initState();
    _izinBermalamData = IzinBermalamBaakController.viewAllRequestsForBaak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Request Izin Bermalam'),
        backgroundColor:
            Colors.blue, // Set the same color as IzinKeluarBaakView
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
                _izinBermalamData =
                    IzinBermalamBaakController.viewAllRequestsForBaak();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.indigo],
          ),
        ),
        child: FutureBuilder<ApiResponse<List<IzinBermalamBaak>>>(
          future: _izinBermalamData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.error != null) {
              return Center(child: Text('Failed to load data.'));
            } else {
              List<IzinBermalamBaak> izinBermalamList = snapshot.data!.data!;
              return ListView.builder(
                itemCount: izinBermalamList.length,
                itemBuilder: (context, index) {
                  IzinBermalamBaak izinBermalam = izinBermalamList[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('ID: ${izinBermalam.userId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason: ${izinBermalam.reason}'),
                          Text('Status: ${izinBermalam.status}'),
                          Text('Start Date: ${izinBermalam.startDate}'),
                          Text('End Date: ${izinBermalam.endDate}'),
                        ],
                      ),
                      trailing: izinBermalam.status == 'approved'
                          ? Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () {
                                approveIzin(izinBermalam.id);
                              },
                              child: Text('Approve'),
                            ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void approveIzin(int izinId) async {
    ApiResponse<String> response =
        await IzinBermalamBaakController.approveIzinBermalam(izinId);
    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: ${response.error}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.data}')),
      );
      setState(() {
        // Refresh data after approval
        _izinBermalamData = IzinBermalamBaakController.viewAllRequestsForBaak();
      });
    }
  }
}
