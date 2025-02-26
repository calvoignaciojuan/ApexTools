import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { createRecord } from 'lightning/uiRecordApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';

import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class TesDataTableDynamic extends NavigationMixin(LightningElement) {

  @track recordId = '006Hn00001O2Ub3IAF';
  @track selectedRecordForDetails = '';

  @track isRightPanelVisible = false;
  @track columns = [];
  @track data = [];
  @track allFunds = []; // To track selected fund IDs
  @track selectedFunds = []; // To track selected fund IDs

  fundValue = [];
  companyValue = [];
  countsMap = new Map();

  get options() {
    return [
      { label: 'Ross', value: 'option1' },
      { label: 'Rachel', value: 'option2' },
    ];
  }

  get selectedValues() {
    return this.value.join(',');
  }

  handleFilterFunds(e) {
    this.fundValue = e.detail.value;
    const showColumnMap = {};
    console.log('this.value ' + JSON.stringify(this.fundValue));
    this.columns.forEach(item => {
      const fundValue = item.value; // Normalize the label
      item.showColumn = this.fundValue.includes(fundValue); // Set showColumn based on presence in values
      showColumnMap[item.id] = item.showColumn;
    });

    // Update the accounts' relatedRecords based on the showColumnMap
    this.data.forEach(account => {
      account.relatedRecords.forEach(record => {
        record.showColumn = showColumnMap[record.columnId] || false; // Update showCloumn based on the map
      });
    });

  }
  handleFilterCompanies(e) {
    this.companyValue = e.detail.value;
    console.log('this.companyValue ' + JSON.stringify(this.companyValue));

    // Update the accounts' relatedRecords based on the showColumnMap
    this.data.forEach(item => {
      const companyValue = item.value; // Normalize the label
      console.log('companyValue ' + companyValue);

      item.showLine = this.companyValue.includes(companyValue); // Set showColumn based on presence in values
      console.log('this.showLine ' + this.companyValue.includes(companyValue));
    });

  }

  handleTypeMenuSelect(event) {
    const selectedValue = event.detail.value;
    if (this.selectedFunds.has(selectedValue)) {
      this.selectedFunds.delete(selectedValue);
    } else {
      this.selectedFunds.add(selectedValue);
    }
  }
  get filteredColumns() {
    return this.columns.filter(column => this.selectedFunds.has(column.id));
  }
  isSelected(value) {
    return this.selectedFunds.has(value);
  }
  connectedCallback() {
    this.initializeData();
    console.log('Hola cogo');
  }

  initializeData() {
    // Sample data for accounts, funds, and opportunities
    const accounts = [
      { id: '001Hn000027ZB7HIAW', name: 'Company A', value: 'company1', label: 'Company A' },
      { id: '001Hn000027ZB8TIAW', name: 'Company B', value: 'company2', label: 'Company B' },
      { id: '001Hn000027ZB8UIAW', name: 'Company C', value: 'company3', label: 'Company C' }
    ];

    const funds = [
      { id: 'a0RHn00000KFjYBMA1', name: 'Fund 1', value: 'fund1', label: 'Fund 1' },
      { id: 'a0RHn00000KFjYGMA1', name: 'Fund 2', value: 'fund2', label: 'Fund 2' },
      { id: 'a0RHn00000KFjYCMA1', name: 'Fund 3', value: 'fund3', label: 'Fund 3' },
      { id: 'a0RHn00000KFjYDMA1', name: 'Fund 4', value: 'fund4', label: 'Fund 4' }
    ];

    const opportunities = [
      { id: '006Hn00001O2Ub3IAF', name: 'Opportunity 1', accountId: '001Hn000027ZB7HIAW', fundId: 'a0RHn00000KFjYBMA1', stage: 'Value Proposition' },
      { id: '006Hn00001O2Ub5IAF', name: 'Opportunity 2', accountId: '001Hn000027ZB7HIAW', fundId: 'a0RHn00000KFjYGMA1', stage: 'Prospecting'},
      { id: '006Hn00001O2Ub6IAF', name: 'Opportunity 3', accountId: '001Hn000027ZB8TIAW', fundId: 'a0RHn00000KFjYBMA1', stage: 'Value Proposition'},
      { id: '006Hn00001O2UbMIAV', name: 'Opportunity 4', accountId: '001Hn000027ZB8UIAW', fundId: 'a0RHn00000KFjYCMA1', stage: 'Qualification'}
    ];

    this.allFunds = funds;
    this.allCompanies = accounts;
    this.selectedFunds = funds;
    this.selectedCompanies = accounts;

    //filters
    this.fundValue = ['fund1', 'fund2', 'fund3', 'fund4'];
    this.companyValue = ['company1', 'company2', 'company3', 'company4'];

    // Define columns for the table based on funds
    this.columns = funds.map(fund => ({
      id: fund.id,
      label: fund.name,
      value: fund.value,
      showColumn: true
    }));
    console.log('this.columns ' + JSON.stringify(this.columns));
    // Prepare data for the table
    const accCount = accounts.length;
    this.data = accounts.map(account => {
      const relatedRecords = funds.map(fund => {
        let oppCount = 0;
        const records = opportunities.filter(opportunity =>
          opportunity.accountId === account.id && opportunity.fundId === fund.id
        );
        if (records.length > 0) {
          let count = this.countsMap.get(fund.id) ? this.countsMap.get(fund.id) : 0;
          count++;
          this.countsMap.set(fund.id, count);
          oppCount++;
        }
        console.log('oppCount ' + oppCount);
        console.log('fund.id ' + fund.id);

        return {
          columnId: fund.id,
          showColumn: true,
          records: records
        };
      });

      return {
        id: account.id,
        name: account.name,
        showLine: true,
        value: account.value,
        relatedRecords: relatedRecords
      };
    });
    console.log('countsMap ' + JSON.stringify(this.countsMap));
    console.log('this.data ' + JSON.stringify(this.data));
    // Initialize selected funds with all funds
    this.selectedFunds = new Set(this.columns.map(column => column.id));
  }

  handleButtonClick(event) {
    const recordId = event.target.dataset.recordId;
    const recordName = event.target.dataset.recordName;
    console.log(`Record ID: ${recordId}, Record Name: ${recordName}`);
  }

  handleButtonClickshowDetails(event) {
    const recordId = event.target.dataset.recordId;
    const recordName = event.target.dataset.recordName;
    console.log(`Record ID: ${recordId}, Record Name: ${recordName}`);

    this.selectedRecordForDetails = recordId;
    this.isRightPanelVisible = true;
  }

  handleNewOpportunityWithRecordPageView(event) {

    const accId = JSON.stringify(event.target.dataset.id1);
    const fundId = JSON.stringify(event.target.dataset.id2);
    console.log(`handleNewOpportunity - Name: ` + JSON.stringify(event.target.dataset.name));
    console.log(`handleNewOpportunity - Acc id: ` + accId);
    console.log(`handleNewOpportunity - Fund id: ` + fundId);

    const defaultValues = encodeDefaultFieldValues({
      Name: 'Sample Opportunity', // Opportunity Name
      CloseDate: '2024-12-31', // Close Date
      StageName: 'Prospecting', // Stage Name
      ForecastCategoryName: 'Pipeline',
      AccountId: accId,
      //Fund__c: fundId
    });
    console.log(defaultValues);

    const pageRef = {
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Opportunity',
        actionName: 'new'
      },
      state: {
        defaultFieldValues: defaultValues,
      }
    };

    // Navigate to the Opportunity creation page
    this[NavigationMixin.Navigate](pageRef);
  }

  handleNewOpportunityWithoutRecordPageView(event) {

    const accId = event.target.dataset.id1 ? String(event.target.dataset.id1) : '';
    console.log('accId ---------->: ' + accId);
    const fundId = event.target.dataset.id2 ? String(event.target.dataset.id2) : '';

     // Define the fields for the Opportunity record creation
     const opportunityFields = {
      Name: 'New Opportunity',  // Default field value for Name (can be customized)
      CloseDate: '2024-12-31',  // Default Close Date
      StageName: 'Prospecting',  // Default Stage
      ForecastCategoryName: 'Pipeline',
      AccountId: accId,
      Fund__c: fundId
     };     

      // Create the Opportunity record using lightning/uiRecordApi
      const recordInput = {
          apiName: OPPORTUNITY_OBJECT.objectApiName,
          fields: opportunityFields
      };
      console.log('creating opp');
      createRecord(recordInput)
          .then((opportunity) => {
              console.log('Opportunity Created with Id: ' + opportunity.id);
              console.log('Opportunity Created with accId: ' + opportunity.AccountId);
              // Optionally, navigate to a custom page after creation or leave it in the same page
              // You can use NavigationMixin or any custom logic for further navigation
          })
          .catch((error) => {
              console.error('Error creating Opportunity: ', error);
          });        
  }


  handleOpenOpportunity(event) {
    // Access the data-record-id attribute when the link is clicked
    const recordId = event.target.dataset.recordId;
    console.log('oppid: ' + recordId);  // Do something with the recordId (e.g., open the Opportunity)

    const pageReference = {
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: 'Opportunity',
        actionName: 'view'
      }
    };

    // Generate the URL for the Opportunity page
    this[NavigationMixin.GenerateUrl](pageReference)
      .then(url => {
        // Open the URL in a new window (or tab)
        window.open(url, '_blank');
      })
      .catch(error => {
        console.error("Error generating URL: ", error);
      });
  }


  oppNameAndStage(event) {
    
    const childName = event.target.dataset.name; // assuming you're passing the name in dataset
    const childStage = event.target.dataset.stage; // assuming you're passing the stage in dataset

    // Concatenate with a dash
    const displayText = `${childName} - ${childStage}`;

    console.log(displayText);  // Logs "child.name - child.stage"
    // Use displayText in your logic if needed
}

  // Get the label dynamically based on the panel visibility
  get toggleButtonLabel() {
    return this.isRightPanelVisible ? 'Hide Details' : 'Show Details';
  }

  handleHidePanel() {
    this.isRightPanelVisible = false; // Hides the panel
}

openRelatedList() {
  this[NavigationMixin.Navigate]({
      type: 'standard__recordRelationshipPage',
      attributes: {
          recordId: '500Hn00001kFlz5IAC',
          objectApiName: 'Case', // Adjust your parent object API name
          relationshipApiName: 'CaseComments', // Adjust your relationship name
          actionName: 'view'
      }
  });
}




}