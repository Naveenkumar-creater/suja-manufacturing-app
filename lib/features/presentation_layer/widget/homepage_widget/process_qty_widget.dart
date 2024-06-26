import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prominous/features/presentation_layer/api_services/actual_qty_di.dart';
import 'package:prominous/features/presentation_layer/api_services/plan_qty_di.dart';
import 'package:prominous/features/presentation_layer/provider/actual_qty_provider.dart';
import 'package:prominous/features/presentation_layer/provider/plan_qty_provider.dart';

class ProcessQtyWidget extends StatefulWidget {
  final int? id;
    final int? psid;
  const ProcessQtyWidget({super.key, required this.id, this.psid});

  @override
  State<ProcessQtyWidget> createState() => _ProcessQtyWidgetState();
}

class _ProcessQtyWidgetState extends State<ProcessQtyWidget> {
  
 ActualQtyService actualQtyService =ActualQtyService();
  PlanQtyService planQtyService=PlanQtyService();
 bool  isLoading = false; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchActualQty();
  }
   


   Future<void> _fetchActualQty() async {
    try {
      await actualQtyService.getActualQty(context: context, id: widget.id??0,psid: widget.psid ??0);

      await planQtyService.getPlanQty(context: context, id: widget.id ??0, psid: widget.psid ??0 );
      setState(() {
        isLoading = true; // Set isLoading to false when data is fetched
      });
    } catch (e) {
      // ignore: avoid_print
      // print('Error fetching asset list: $e');
      setState(() {
        isLoading = false; // Set isLoading to false even if there's an error
      });
    }
  }
  @override
    
  Widget build(BuildContext context) {
    final planQty = Provider.of<PlanQtyProvider>(context, listen: true).user?.planQtyCountEntity?.planQty;


     final actualQty = Provider.of<ActualQtyProvider>(context, listen: true).user?.actualQtyCountEntity?.actualQty;

    //  int? achivedProduct=;

    return  Container(
                                              width: double.infinity,
                                              height: 170,
                                              decoration: BoxDecoration(),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                     
                                                      height: 170,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8))),
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '${planQty}'?? "0",
                                                           
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          42,
                                                                      color: Colors
                                                                          .grey)),
                                                                          Text('Planned Qty',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                           
                                                      height: 170,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8))),
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "${actualQty}"??"0",
                                                          
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          42,
                                                                      color: Colors
                                                                          .grey)),
                                                                            Text('Actual Qty',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                   
                                                      height: 170,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8))),
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                         Text(
  // '${((actualQty ?? 0) / (planQty ?? 1) * 100).toStringAsFixed(2)}%' ?? "0%",

"0",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          42,
                                                                      color: Colors
                                                                          .grey)),
                                                                          Text('Team Productivity',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                    
                                                      height: 170,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8))),
                                                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '0',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          42,
                                                                      color: Colors
                                                                          .grey)),
                                                                          Text('Forecast Completion Percentage ',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
  }
}