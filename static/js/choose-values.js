function replaceValueEditor(prefix, option) {
  var feld = option.value.replace(/\s/g, "-");
  Influx.restxq(prefix + "/api/sanofi/choose-values/" + feld);
}