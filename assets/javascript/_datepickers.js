// import Moment from 'moment';
// import Pikaday from 'pikaday';

function setup_datepicker(element){
  var picker = new Pikaday({
    field: element,
    format: "DD/MM/YYYY",
    firstDay: 1,
    yearRange: [2013,2050],
    toString(date, format){
      const day = ("0" + date.getDate()).slice(-2);
      const month = ("0" + (date.getMonth() + 1)).slice(-2);
      const year = date.getFullYear();
      return `${day}/${month}/${year}`;
    }
  });
  return picker;
}
