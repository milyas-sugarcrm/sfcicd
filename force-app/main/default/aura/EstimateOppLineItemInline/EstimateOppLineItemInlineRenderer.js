({
  //
  // Your renderer method overrides go here

  afterRender: function (component, helper) {
    // document.getElementsById("hoverDiv").disabled= true;

    console.log("In function " + component.get("v.SalesStage"));

    //  if(component.get("v.SalesStage")==='true')
    // {
    //     var elms = document.querySelectorAll("[class='disable']");
    // var elm =  document.getElementsByClassName('disable');
    //console.log("In function elm "+ component.get("v.SalesStage"));
    //  console.log('Length of elm is : '+ elm.length);
    //    console.log('Length of elms is : '+ elms.length);
    // console.log(elms);
    //   for(var i = 0; i < elms.length; i++) {
    //        elms[i].disabled= true;
    //     }
  }
});
