import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class JsonFieldViewer extends LightningElement {
    @api recordId; // Record ID passed from Lightning Record Page
    @api objectApiName; // Object API Name passed dynamically
    @api jsonFieldName; // Name of the field containing JSON structure
    @api sectionName; // Configurable section name

    isExpanded = true; // Controls whether the section is expanded
    fieldValues = []; // Array to store Name-Value pairs
    error;

    get hasFieldValues() {
        return this.fieldValues.length > 0;
    }

     // Dynamically determine icon name based on section state
     get iconName() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    // Dynamically determine the class for section content
    get contentClass() {
        return this.isExpanded ? 'slds-section slds-is-open' : 'slds-section';
    }

    // Toggle section visibility
    toggleSection() {
        this.isExpanded = !this.isExpanded;
        console.log(this.isExpanded);
    }


    // Dynamically construct the field path for the JSON field
    get fieldPathArray() {
        return [`${this.objectApiName}.${this.jsonFieldName}`];
    }

    // Fetch the JSON field data dynamically
    @wire(getRecord, { recordId: '$recordId', fields: '$fieldPathArray' })
    wiredRecord({ error, data }) {
        if (data) {
            this.error = undefined;

            const jsonField = data.fields[this.jsonFieldName]?.value;
            if (jsonField) {
                try {
                    const parsedJson = JSON.parse(jsonField); // Parse JSON string
                    this.processJson(parsedJson); // Process JSON structure
                } catch (err) {
                    this.error = 'Invalid JSON format in the field';
                }
            } else {
                this.error = `Field ${this.jsonFieldName} is empty or not found.`;
            }
        } else if (error) {
            this.error = error;
            this.fieldValues = [];
        }
    }

    // Process the JSON structure to extract field-value pairs
    processJson(parsedJson) {
        this.fieldValues = Object.entries(parsedJson).map(([key, value]) => {
            if (Array.isArray(value) && value.every(item => typeof item === 'string')) {
                // Convert array of strings to comma-separated values
                return { name: key, value: value.join(', ') };
            } else {
                // Handle simple types
                return { name: key, value: value };
            }
        });
    }
}
