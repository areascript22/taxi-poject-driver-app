class Succes {
  int code;
  String response;

  Succes({
    required this.code,
    required this.response,
  });
}


class Failure {
  int code;
  String errorResponse;

  Failure({
    required this.code,
    required this.errorResponse,
  });
}
