class Succes {
  int code;
  Object response;

  Succes({
    required this.code,
    required this.response,
  });
}


class Failure {
  int code;
  Object errorResponse;

  Failure({
    required this.code,
    required this.errorResponse,
  });
}
