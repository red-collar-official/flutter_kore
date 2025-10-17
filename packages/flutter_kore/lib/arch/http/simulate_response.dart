/// Class to simulate server response
class SimulateResponse {
  /// raw data from server
  final dynamic data;

  /// Headers of server response
  final Map? headers;

  /// Status code for server response
  final int statusCode;

  SimulateResponse({
    this.data,
    this.headers,
    this.statusCode = 200,
  });
}
