//= require tablesort
//= require_directory ./sorts
//= require pikaday
//= require_self
//= require_tree .

window.onload = function(){
  var currentTable = $("#table-sortable")[0];
  if (currentTable != null){
    new Tablesort(currentTable);
  }
} 
