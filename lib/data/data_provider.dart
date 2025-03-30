import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:holz_logistik/data/models.dart';
import 'package:holz_logistik/data/database_helper.dart';

/// ======================================= Sync Status ======================================= ///

enum SyncStatus { synced, syncing, pending, failed, offline }

/// ======================================= WebSocket Message ======================================= ///

class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage({required this.type, required this.data});

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'],
      data: json['data'],
    );
  }
}

/// ======================================= WebSocket Service ======================================= ///

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  final String _wsUrl = 'wss://your-api-endpoint.com/ws';

  WebSocketChannel? _channel;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionStatusController =
      BehaviorSubject<SyncStatus>.seeded(SyncStatus.offline);

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = false;
  bool _wasConnected = false;
  bool _intentionalClosure = false;

  final List<WebSocketMessage> _offlineQueue = [];

  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<SyncStatus> get connectionStatus => _connectionStatusController.stream;

  WebSocketService._internal();

  void init() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

    Connectivity().checkConnectivity().then(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty && results.first != ConnectivityResult.none;

    if (_isConnected && !_wasConnected) {
      connect();
    } else if (!_isConnected && _wasConnected) {
      _connectionStatusController.add(SyncStatus.offline);
      _disconnect(reconnect: false);
    }
  }

  Future<void> connect() async {
    if (_channel != null) {
      return;
    }

    _intentionalClosure = false;
    _connectionStatusController.add(SyncStatus.syncing);

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _authenticate();

      _connectionStatusController.add(SyncStatus.synced);

      _processOfflineQueue();
    } catch (e) {
      print('WebSocket connection failed: $e');
      _connectionStatusController.add(SyncStatus.failed);

      _scheduleReconnect();
    }
  }

  void _authenticate() {
    send(WebSocketMessage(
      type: 'auth',
      data: {
        'token': 'your-auth-token', // Replace with your actual auth token
      },
    ));
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      final wsMessage = WebSocketMessage.fromJson(message);

      if (wsMessage.type == 'auth_response') {
        if (wsMessage.data['success'] == true) {
          _requestInitialData();
        } else {
          print('Authentication failed: ${wsMessage.data['message']}');
          _connectionStatusController.add(SyncStatus.failed);
          _disconnect(reconnect: true);
        }
      } else if (wsMessage.type == 'ping') {
        send(WebSocketMessage(type: 'pong', data: {}));
      } else {
        _messageController.add(wsMessage);
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _connectionStatusController.add(SyncStatus.failed);
    _disconnect(reconnect: true);
  }

  void _onDone() {
    print('WebSocket connection closed');

    if (!_intentionalClosure) {
      _connectionStatusController.add(SyncStatus.failed);
      _disconnect(reconnect: true);
    }
  }

  void _disconnect({bool reconnect = false}) {
    _channel?.sink.close();
    _channel = null;

    if (reconnect && _isConnected) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    Future.delayed(Duration(seconds: 5), () {
      if (_isConnected) {
        connect();
      }
    });
  }

  void _requestInitialData() {
    send(WebSocketMessage(
      type: 'sync_request',
      data: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }

  void send(WebSocketMessage message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message.toJson()));
      } catch (e) {
        print('Failed to send message: $e');
        _queueMessageForLater(message);
      }
    } else {
      _queueMessageForLater(message);
    }
  }

  void _queueMessageForLater(WebSocketMessage message) {
    _offlineQueue.add(message);
    _connectionStatusController.add(SyncStatus.pending);
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) {
      return;
    }

    _connectionStatusController.add(SyncStatus.syncing);

    final queueCopy = List<WebSocketMessage>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final message in queueCopy) {
      send(message);
      await Future.delayed(Duration(milliseconds: 100));
    }

    _connectionStatusController.add(SyncStatus.synced);
  }

  void requestFullSync() {
    send(WebSocketMessage(
      type: 'full_sync_request',
      data: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }

  void close() {
    _intentionalClosure = true;
    _messageController.close();
    _connectionStatusController.close();
    _connectivitySubscription.cancel();
    _disconnect(reconnect: false);
  }
}

/// ======================================= Data Repository ======================================= ///

class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;

  final DatabaseHelper _db = DatabaseHelper.instance;
  final WebSocketService _wsService = WebSocketService();

  List<Contract> _activeContracts = [];
  List<Contract> _doneContracts = [];
  List<Shipment> _shipments = [];
  List<Location> _activeLocations = [];
  List<Location> _doneLocations = [];

  final _activeContractStreamController = BehaviorSubject<List<Contract>>();
  final _doneContractStreamController = BehaviorSubject<List<Contract>>();
  final _shipmentStreamController = BehaviorSubject<List<Shipment>>();
  final _activeLocationStreamController = BehaviorSubject<List<Location>>();
  final _doneLocationStreamController = BehaviorSubject<List<Location>>();

  final _contractStreamControllers = <int, BehaviorSubject<Contract>>{};
  final _locationStreamControllers = <int, BehaviorSubject<Location>>{};
  final _shipmentStreamControllers = <int, BehaviorSubject<Shipment>>{};

  Stream<List<Contract>> get activeContractStream =>
      _activeContractStreamController.stream;
  Stream<List<Contract>> get doneContractStream =>
      _doneContractStreamController.stream;
  Stream<List<Shipment>> get shipmentStream => _shipmentStreamController.stream;
  Stream<List<Location>> get activeLocationStream =>
      _activeLocationStreamController.stream;
  Stream<List<Location>> get doneLocationStream =>
      _doneLocationStreamController.stream;
  Stream<SyncStatus> get syncStatusStream => _wsService.connectionStatus;

  List<Contract> get activeContracts => _activeContracts;
  List<Contract> get doneContracts => _doneContracts;
  List<Shipment> get shipments => _shipments;
  List<Location> get activeLocations => _activeLocations;
  List<Location> get doneLocations => _doneLocations;

  late StreamSubscription<WebSocketMessage> _messageSubscription;

  DataRepository._internal() {
    _initWebSocketListeners();
    _wsService.init();
    _wsService.connect();
  }

  void _initWebSocketListeners() {
    _messageSubscription = _wsService.messages.listen((message) {
      switch (message.type) {
        case 'user_update':
          _handleUserUpdate(message.data);
          break;
        case 'contract_update':
          _handleContractUpdate(message.data);
          break;
        case 'quantity_update':
          _handleQuantityUpdate(message.data);
          break;
        case 'shipment_update':
          _handleShipmentUpdate(message.data);
          break;
        case 'location_update':
          _handleLocationUpdate(message.data);
          break;
        case 'full_sync_complete':
          loadAllData();
          break;
      }
    });
  }

  Stream<Contract> getContractStream(int id) {
    if (!_contractStreamControllers.containsKey(id)) {
      _contractStreamControllers[id] = BehaviorSubject<Contract>();
      _updateContractStreamController(id);
    }
    return _contractStreamControllers[id]!.stream;
  }

  Stream<Shipment> getShipmentStream(int id) {
    if (!_shipmentStreamControllers.containsKey(id)) {
      _shipmentStreamControllers[id] = BehaviorSubject<Shipment>();
      _updateShipmentStreamController(id);
    }
    return _shipmentStreamControllers[id]!.stream;
  }

  Stream<Location> getLocationStream(int id) {
    if (!_locationStreamControllers.containsKey(id)) {
      _locationStreamControllers[id] = BehaviorSubject<Location>();
      _updateLocationStreamController(id);
    }
    return _locationStreamControllers[id]!.stream;
  }

  void _updateContractStreamController(int id) {
    Contract? contract;
    try {
      contract = _activeContracts.firstWhere((c) => c.id == id);
    } catch (_) {
      try {
        contract = _doneContracts.firstWhere((c) => c.id == id);
      } catch (_) {
        // Contract not found in memory
        return;
      }
    }

    if (_contractStreamControllers.containsKey(id)) {
      _contractStreamControllers[id]!.add(contract);
    }
  }

  void _updateShipmentStreamController(int id) {
    try {
      final shipment = _shipments.firstWhere((s) => s.id == id);
      if (_shipmentStreamControllers.containsKey(id)) {
        _shipmentStreamControllers[id]!.add(shipment);
      }
    } catch (_) {
      // Shipment not found in memory
    }
  }

  void _updateLocationStreamController(int id) {
    Location? location;
    try {
      location = _activeLocations.firstWhere((l) => l.id == id);
    } catch (_) {
      try {
        location = _doneLocations.firstWhere((l) => l.id == id);
      } catch (_) {
        // Location not found in memory
        return;
      }
    }

    if (_locationStreamControllers.containsKey(id)) {
      _locationStreamControllers[id]!.add(location);
    }
  }

  Future<void> _loadActiveContracts() async {
    _activeContracts = await _db.getActiveContracts();
    _activeContractStreamController.add(_activeContracts);

    for (final contract in _activeContracts) {
      if (_contractStreamControllers.containsKey(contract.id)) {
        _contractStreamControllers[contract.id]!.add(contract);
      }
    }
  }

  Future<void> _loadDoneContracts() async {
    _doneContracts = await _db.getDoneContracts();
    _doneContractStreamController.add(_doneContracts);

    for (final contract in _doneContracts) {
      if (_contractStreamControllers.containsKey(contract.id)) {
        _contractStreamControllers[contract.id]!.add(contract);
      }
    }
  }

  Future<void> _loadShipments() async {
    _shipments = await _db.getShipments();
    _shipmentStreamController.add(_shipments);

    for (final shipment in _shipments) {
      if (_shipmentStreamControllers.containsKey(shipment.id)) {
        _shipmentStreamControllers[shipment.id]!.add(shipment);
      }
    }
  }

  Future<void> _loadActiveLocations() async {
    _activeLocations = await _db.getActiveLocations();
    _activeLocationStreamController.add(_activeLocations);

    for (final location in _activeLocations) {
      if (_locationStreamControllers.containsKey(location.id)) {
        _locationStreamControllers[location.id]!.add(location);
      }
    }
  }

  Future<void> _loadDoneLocations() async {
    _doneLocations = await _db.getDoneLocations();
    _doneLocationStreamController.add(_doneLocations);

    for (final location in _doneLocations) {
      if (_locationStreamControllers.containsKey(location.id)) {
        _locationStreamControllers[location.id]!.add(location);
      }
    }
  }

  Future<void> loadAllData() async {
    await _loadActiveContracts();
    await _loadDoneContracts();
    await _loadShipments();
    await _loadActiveLocations();
    await _loadDoneLocations();
  }

  void _handleUserUpdate(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    if (data['deleted'] == true || data['deleted'] == 1) {
      await db.deleteUser(data['id']);
    } else {
      await db.insertOrUpdateUser(data);
    }

    await loadAllData();
  }

  void _handleContractUpdate(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    if (data['deleted'] == true || data['deleted'] == 1) {
      await db.deleteContract(data['id']);
    } else {
      await db.insertOrUpdateContract(data);
    }

    if (data['done'] == 1) {
      await _loadDoneContracts();
    } else {
      await _loadActiveContracts();
    }
  }

  void _handleQuantityUpdate(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    if (data['deleted'] == true || data['deleted'] == 1) {
      await db.deleteQuantity(data['id']);
    } else {
      await db.insertOrUpdateQuantity(data);
    }

    await loadAllData();
  }

  void _handleShipmentUpdate(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    if (data['deleted'] == true || data['deleted'] == 1) {
      await db.deleteShipment(data['id']);
    } else {
      await db.insertOrUpdateShipment(data);
    }

    await _loadShipments();
    await _loadActiveLocations();
    await _loadDoneLocations();
  }

  void _handleLocationUpdate(Map<String, dynamic> data) async {
    final db = DatabaseHelper.instance;

    if (data['deleted'] == true || data['deleted'] == 1) {
      await db.deleteLocation(data['id']);
    } else {
      await db.insertOrUpdateLocation(data);
    }

    if (data['done'] == 1) {
      await _loadDoneLocations();
    } else {
      await _loadActiveLocations();
    }
  }

  Future<void> addContract(Contract contract) async {
    final data = _db.getUpdateMap(contract.toMap(), done: false);

    await _db.insertOrUpdateContract(data);

    _wsService.send(WebSocketMessage(type: 'contract_update', data: data));

    await _loadActiveContracts();
  }

  Future<void> updateContract(Contract contract, {bool isDone = false}) async {
    final data = _db.getUpdateMap(contract.toMap(), done: isDone);

    await _db.insertOrUpdateContract(data);

    _wsService.send(WebSocketMessage(type: 'contract_update', data: data));

    if (isDone) {
      await _loadDoneContracts();
    } else {
      await _loadActiveContracts();
    }

    if (_contractStreamControllers.containsKey(contract.id)) {
      _contractStreamControllers[contract.id]!.add(contract);
    }
  }

  Future<bool> deleteContract(int id) async {
    if (await _db.isContractUsed(id)) {
      return false;
    }

    await _db.deleteContract(id);

    _wsService.send(WebSocketMessage(
      type: 'contract_update',
      data: {
        'id': id,
        'deleted': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));

    await _loadActiveContracts();
    await _loadDoneContracts();

    return true;
  }

  Future<void> addQuantity(Quantity quantity) async {
    final data = _db.getUpdateMap(quantity.toMap(), done: false);

    await _db.insertOrUpdateQuantity(data);

    _wsService.send(WebSocketMessage(type: 'quantity_update', data: data));
  }

  Future<void> updateQuantity(Quantity quantity) async {
    final data = _db.getUpdateMap(quantity.toMap());

    await _db.insertOrUpdateQuantity(data);

    _wsService.send(WebSocketMessage(type: 'quantity_update', data: data));
  }

  Future<void> deleteQuantity(int quantityId) async {
    await deleteQuantity(quantityId);

    _wsService.send(WebSocketMessage(
      type: 'quantity_update',
      data: {
        'id': quantityId,
        'deleted': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }

  Future<void> addShipment(Shipment shipment) async {
    final data = _db.getUpdateMap(shipment.toMap());

    await _db.insertOrUpdateShipment(data);
    await addQuantity(shipment.quantity!);

    _wsService.send(WebSocketMessage(type: 'shipment_update', data: data));

    await _loadShipments();
    await _loadActiveLocations();
    await _loadDoneLocations();
  }

  Future<void> deleteShipment(int shipmentId, int quantityId) async {
    await _db.deleteShipment(shipmentId);
    await deleteQuantity(quantityId);

    _wsService.send(WebSocketMessage(
      type: 'shipment_update',
      data: {
        'id': shipmentId,
        'deleted': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));

    await _loadShipments();
    await _loadActiveLocations();
    await _loadDoneLocations();
  }

  Future<void> addLocation(Location location) async {
    final data = _db.getUpdateMap(location.toMap(), done: false);

    await _db.insertOrUpdateLocation(data);
    await addQuantity(location.initialQuantity!);
    await addQuantity(location.currentQuantity!);

    _wsService.send(WebSocketMessage(type: 'location_update', data: data));

    await _loadActiveLocations();
  }

  Future<void> updateLocation(Location location, {bool isDone = false}) async {
    final data = _db.getUpdateMap(location.toMap(), done: isDone);

    await _db.insertOrUpdateLocation(data);
    await updateQuantity(location.initialQuantity!);
    await updateQuantity(location.currentQuantity!);

    _wsService.send(WebSocketMessage(type: 'location_update', data: data));

    if (isDone) {
      await _loadDoneLocations();
    } else {
      await _loadActiveLocations();
    }

    if (_locationStreamControllers.containsKey(location.id)) {
      _locationStreamControllers[location.id]!.add(location);
    }
  }

  Future<void> deleteLocation(Location location) async {
    final int locationId = location.id;
    final int initialQuantityId = location.initQuantityId;
    final int currentQuantityId = location.currQuantityId;

    await _db.deleteLocation(locationId);
    await deleteQuantity(initialQuantityId);
    await deleteQuantity(currentQuantityId);
    await Future.wait(location.shipments!
        .map((shipment) => deleteShipment(shipment.id, shipment.quantityId)));

    _wsService.send(WebSocketMessage(
      type: 'location_update',
      data: {
        'id': locationId,
        'deleted': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));

    await _loadActiveLocations();
    await _loadDoneLocations();
  }

  void requestFullSync() {
    _wsService.requestFullSync();
  }

  void dispose() {
    _messageSubscription.cancel();
    _wsService.close();

    _activeContractStreamController.close();
    _doneContractStreamController.close();
    _shipmentStreamController.close();
    _activeLocationStreamController.close();
    _doneLocationStreamController.close();

    for (final controller in _contractStreamControllers.values) {
      controller.close();
    }
    _contractStreamControllers.clear();

    for (final controller in _locationStreamControllers.values) {
      controller.close();
    }
    _locationStreamControllers.clear();

    for (final controller in _shipmentStreamControllers.values) {
      controller.close();
    }
    _shipmentStreamControllers.clear();
  }
}

/// ======================================= Widget-specific Data Providers ======================================= ///

class ContractProvider {
  final DataRepository _repository = DataRepository();

  Stream<Contract> getContractStream(int id) =>
      _repository.getContractStream(id);

  Stream<List<Contract>> get activeContracts =>
      _repository.activeContractStream;

  Stream<List<Contract>> get doneContracts => _repository.doneContractStream;

  Future<void> addContract(Contract contract) =>
      _repository.addContract(contract);

  Future<void> updateContract(Contract contract, {bool isDone = false}) =>
      _repository.updateContract(contract, isDone: isDone);

  Future<void> deleteContract(int id) => _repository.deleteContract(id);
}

class ShipmentProvider {
  final DataRepository _repository = DataRepository();

  Stream<Shipment> getShipmentStream(int id) =>
      _repository.getShipmentStream(id);

  Stream<List<Shipment>> get shipments => _repository.shipmentStream;

  Future<void> addShipment(Shipment shipment) =>
      _repository.addShipment(shipment);

  Future<void> deleteShipment(int shipmentId, int quantityId) =>
      _repository.deleteShipment(shipmentId, quantityId);
}

class LocationProvider {
  final DataRepository _repository = DataRepository();

  Stream<Location> getLocationStream(int id) =>
      _repository.getLocationStream(id);

  Stream<List<Location>> get activeLocations =>
      _repository.activeLocationStream;

  Stream<List<Location>> get doneLocations => _repository.doneLocationStream;

  Future<void> addLocation(Location location) =>
      _repository.addLocation(location);

  Future<void> updateLocation(Location location, {bool isDone = false}) =>
      _repository.updateLocation(location, isDone: isDone);

  Future<void> deleteLocation(Location location) =>
      _repository.deleteLocation(location);
}

class SyncStatusProvider {
  final DataRepository _repository = DataRepository();

  Stream<SyncStatus> get syncStatus => _repository.syncStatusStream;

  void requestFullSync() => _repository.requestFullSync();
}
