import { LightningElement, track, wire } from 'lwc';
import getSaidDetails from "@salesforce/apex/SaidController.getSaidDetails";
import saveSAId from "@salesforce/apex/SaidController.saveSAId";


export default class SAIDSearchComp extends LightningElement {

    @track disableBtn = true;
    @track holidayData;
    @track year;

   /* connectedCallback(){

    }*/

    inputHandler (event){
        event.target.value.length === 13 ? this.disableBtn = false : this.disableBtn = true;

    }

    searchHandler (){
        const inputBox = this.template.querySelector("lightning-input");
        let isError = this.template.querySelector(".slds-has-error");
    
        //if no error then only call apex from handleSubmit
        if(!isError) {
                //this.template.querySelector("lightning-record-edit-form").submit();
            const saidDate = new Date(inputBox.value.substring(0, 2), inputBox.value.substring(2, 4) - 1, inputBox.value.substring(4, 6));
            this.year = saidDate.getFullYear();
            const saIdObj = {
                year: saidDate.getFullYear(),
                saidNumber: inputBox.value,
                gender: (inputBox.value.substring(6, 10)) <= 4999 ? 'Female' : 'Male',
                citizen: (inputBox.value.substring(10, 11)) == 0 ? 'Citizen' : 'Resident'

            };
            getSaidDetails({payload : JSON.stringify(saIdObj)})
            .then((result)=> {
                console.log('Webservice call is successfull');
                console.log('result==> inside JS '+result);
                this.holidayData = JSON.parse(JSON.stringify(result));
                console.log('name==>  inside JS '+this.holidayData.name);
            })
            .catch((error) => {
                console.error('Error in calling webservice'+JSON.stringify(error));
            });

            saveSAId({payload : JSON.stringify(saIdObj)});
        }
        
        inputBox.value = "";
        this.disableBtn = true;
    }


}