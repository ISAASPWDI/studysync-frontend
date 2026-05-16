// lib/core/utils/timeago_es.dart
import 'package:timeago/timeago.dart' as timeago;

class EsMessages implements timeago.LookupMessages {
  @override String prefixAgo() => 'hace';
  @override String prefixFromNow() => 'en';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => 'justo ahora';
  @override String aboutAMinute(int minutes) => '1 min';
  @override String minutes(int minutes) => '$minutes min';
  @override String aboutAnHour(int minutes) => '1 hora';
  @override String hours(int hours) => '$hours horas';
  @override String aDay(int hours) => '1 día';
  @override String days(int days) => '$days días';
  @override String aboutAMonth(int days) => '1 mes';
  @override String months(int months) => '$months meses';
  @override String aboutAYear(int year) => '1 año';
  @override String years(int years) => '$years años';
  @override String wordSeparator() => ' ';
}

void registerTimeagoLocales() {
  timeago.setLocaleMessages('es', EsMessages());
}
