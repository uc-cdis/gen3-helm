#!/bin/bash

ENV_FILE="../.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    touch "$ENV_FILE"

    # Get today's date in the format YYYYMMDD
    DATE=$(date +"%Y%m%d")

    # Populate .env file with variables
    echo "DICTIONARY_URL='https://pcdc-dev-dictionaries.s3.amazonaws.com/pcdc-schema-dev-20230912.json'" > "$ENV_FILE"
    echo "PROGRAM_NAME='pcdc'" >> "$ENV_FILE"
    echo "PROJECT_CODE='$DATE'" >> "$ENV_FILE"
    echo "SAMPLE=400" >> "$ENV_FILE"
    echo "BASE_URL='<http://localhost>'" >> "$ENV_FILE"
    echo "LOCAL_FILE_PATH='../fake_data/data-simulator'" >> "$ENV_FILE"
    echo "FILE_TYPE='json'" >> "$ENV_FILE"
    echo "TYPES=[\"program\", \"adverse_event\", \"biopsy_surgical_procedure\", \"biospecimen\", \"cellular_immunotherapy\", \"concomitant_medication\", \"core_metadata_collection\", \"cytology\", \"disease_characteristic\", \"external_reference\", \"family_medical_history\", \"function_test\", \"growing_teratoma_syndrome\", \"histology\", \"imaging\", \"immunohistochemistry\", \"lab\", \"late_effect\", \"lesion_characteristic\", \"medical_history\", \"minimal_residual_disease\", \"molecular_analysis\", \"myeloid_sarcoma_involvement\", \"non_protocol_therapy\", \"off_protocol_therapy_study\", \"patient_reported_outcomes_metadata\", \"person\", \"project\", \"protocol_treatment_modification\", \"radiation_therapy\", \"secondary_malignant_neoplasm\", \"staging\", \"stem_cell_transplant\", \"study\", \"subject\", \"subject_response\", \"survival_characteristic\", \"timing\", \"total_dose\", \"transfusion_medicine_procedure\", \"tumor_assessment\", \"vital\"]" >> "$ENV_FILE"
    echo "PROJECT_LIST=[\"pcdc-$DATE\"]" >> "$ENV_FILE"
    echo "CREDENTIALS='../credentials.json'" >> "$ENV_FILE"
    echo "LOCAL_ES_FILE_PATH='../files/pcdc_data.json'" >> "$ENV_FILE"
    echo "ES_PORT=9200" >> "$ENV_FILE"
    echo "INDEX_NAME='pcdc-$DATE'" >> "$ENV_FILE"
fi

chmod +x "$(dirname "$0")"/*.sh

./load_gen3_etl.sh

./generate_data.sh

./load_graph_db.sh

./load_elasticsearch.sh