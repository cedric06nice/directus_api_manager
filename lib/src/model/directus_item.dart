import 'package:directus_api_manager/src/model/directus_data.dart';

abstract class DirectusItem extends DirectusData {
  // Creates a new [DirectusItem]
  DirectusItem(Map<String, dynamic> rawReceivedData) : super(rawReceivedData);

  String get endpointName;
}
