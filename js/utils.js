var g_alert_timeout_id = undefined;
var g_alert_aid = undefined;
function set_alert_timeout() {
	g_alert_aid.attr('class', "alert alert-success").text("");
}

function set_alert(id, type, txt, timeout) {
	if (timeout === undefined) {
		timeout = 5000;
	}
	// success, info, warning, danger
	switch (type) {
		case "error":
			type="danger";
			break;
		case "success":
		case "info":
		case "warning":
		case "danger":
			break;
		default:
			type="danger";
			break;
	}
	g_alert_aid=$("#"+id);
	g_alert_aid.attr('class', "alert alert-" + type);
	g_alert_aid.text(txt);
	if (timeout > 0) {
		if (g_alert_timeout_id != undefined) {
			clearTimeout(g_alert_timeout_id);
		}
		g_alert_timeout_id = setTimeout(set_alert_timeout, timeout);
	}
}

function capitalize(txt) {
  var ctext = txt.charAt(0).toUpperCase() + txt.substring(1).toLowerCase();
  return ctext;
};

if (!String.format) {
  String.format = function(format) {
    var args = Array.prototype.slice.call(arguments, 1);
    return format.replace(/{(\d+)}/g, function(match, number) {
      return typeof args[number] != 'undefined' ? args[number] : match;
    });
  };
}

if (!Object.keys) {
  Object.keys = (function() {
    'use strict';
    var hasOwnProperty = Object.prototype.hasOwnProperty,
      hasDontEnumBug = !({
        toString: null
      }).propertyIsEnumerable('toString'),
      dontEnums = [
        'toString',
        'toLocaleString',
        'valueOf',
        'hasOwnProperty',
        'isPrototypeOf',
        'propertyIsEnumerable',
        'constructor'
      ],
      dontEnumsLength = dontEnums.length;

    return function(obj) {
      if (typeof obj !== 'object' && (typeof obj !== 'function' || obj === null)) {
        throw new TypeError('Object.keys called on non-object');
      }

      var result = [],
        prop, i;

      for (prop in obj) {
        if (hasOwnProperty.call(obj, prop)) {
          result.push(prop);
        }
      }

      if (hasDontEnumBug) {
        for (i = 0; i < dontEnumsLength; i++) {
          if (hasOwnProperty.call(obj, dontEnums[i])) {
            result.push(dontEnums[i]);
          }
        }
      }
      return result;
    };
  }());
}
