/// Class to simulate server response
class SimulateResponse {
  /// raw data from server
  final dynamic data;

  /// Headers of server response
  final Map? headers;

  /// Status code for server response
  final int statusCode;

  // coverage:ignore-start
  const SimulateResponse({this.data, this.headers, this.statusCode = 200});
  // coverage:ignore-end
}
