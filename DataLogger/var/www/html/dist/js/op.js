function tableMarkupFromObjectArray(obj) {
      let headers = `
      ${Object.keys(obj[0]).map((col) => {
        return `<th>${col}</th>`;
      }).join('')}`;

      let content = obj.map((row, idx) => {
        return `<tr>
          ${Object.values(row).map((datum) => {

          /* If we encounter an array:
                [0] = Value,
                [1] (if exists) = PLC memory write address
                [2] (if exists) = a multiplier for converting to the correct numerical format
          */
          if( Array.isArray(datum) ) {
              if(datum.length==3)       // this catches and handles setting the tank levels as they require a decimal eg 110 m3 needs to be entered as 1100 (110.0)
                return `<td><input type="number" class="form-control" value="${datum[0]}" data-writeaddr="${datum[1]}" data-multiplier="${datum[2]}"></input></td>`;
              else {                    // this will be all other array (writable) enteries, eg value & address
                if(datum[0]=="ON")
                    return `<td><select name="name" class="form-control" data-writeaddr="${datum[1]}"><option selected value="1">ON</option><option value="0">OFF</option></select>`;
                else if(datum[0]=="OFF")
                    return `<td><select name="name" class="form-control" data-writeaddr="${datum[1]}"><option selected value="0">OFF</option><option value="1">ON</option></select>`;

                else if(datum[0]=="LOADING")
                    return `<td><select name="name" data-writeaddr="${datum[1]}"><option selected value="0">LOADING</option><option value="1">PAUSE</option></select>`;
                else if(datum[0]=="PAUSED")
                    return `<td><select name="name" data-writeaddr="${datum[1]}"><option selected value="1">PAUSED</option><option value="0">RESUME</option></select>`;

                else
                  return `<td><input type="number" class="form-control" value="${datum[0]}" data-writeaddr="${datum[1]}"></input></td>`;
              }
          }
          else { // all non arrays (non writable) entries
            return `<td>${datum}</td>`;
          }

        }).join('')}
        </tr>`;
      }).join('');

      let tablemarkup = `
      <table class="table table-condensed table-bordered table-hover table-striped">
        ${headers}
        ${content}
      </table>`;
    return tablemarkup;
}

function writePLC(addr, data) {
  console.log("addr:" + addr );
  console.log("data:" + data );

  $.ajax({
    url: 'writePLC.php',
    type: 'post',
    data: {addr: addr, data: data},
    success: function(data){
      // verify it wrote successfully by refreshing (reading) the PLC
      // setTimeout(getPLCData,1000);
    },
 });

}

$(function() { // document.ready()

  // on an input element change event write data to PLC
  $("#pointTable, #tankTable, #miscTable").on("change", "input", function() {
    // if we find a multiplier we use it otherwise we set it to 1
    var multiplier = $(this).attr('data-multiplier');
    if (typeof multiplier === typeof undefined && multiplier !== false) {
        multiplier = 1;
    }
    writePLC( $(this).attr('data-writeaddr'), $(this).val() * multiplier );
  });

  // on a select element (list) change event write data to PLC
  $("#pointTable, #tankTable, #miscTable").on("change", "select", function() {
    writePLC( $(this).attr('data-writeaddr'), $(this).val() );

    /* without a delay this does not get a HTTP 200. If this was moved to the writePLC function it may work, but we only need to update
       after a select change as there is no point fetching after a change to an input as the input already has the populaed value */
    setTimeout(getPLCData,500);
  });

});
