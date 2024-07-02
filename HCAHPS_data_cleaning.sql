-- clean the data and upload it into a new table "tableau_file" 
create table "postgres"."Hospital_Data".Tableau_File as

-- cleaning the hospital_beds table

-- make a cte with all the changes
	-- change the fiscal begin and end date to DATE data type 
	-- If provider_ccn values are not 6 digits, add 0 infront to make it 6 digits
	-- use a partition to see which hospitals have reported more than once

with hospital_beds_prep as
(
select 	lpad(cast(provider_ccn as text),6,'0') as provider_ccn
		,hospital_name
		,to_date(fiscal_year_begin_date, 'MM/DD/YYYY') AS fiscal_year_begin_date
		,to_date(fiscal_year_end_date, 'MM/DD/YYYY') AS fiscal_year_end_date
		,number_of_beds
		,row_number() over (partition by provider_ccn order by to_date(fiscal_year_end_date, 'MM/DD/YYYY') desc) AS nth_row
from "postgres"."Hospital_Data".hospital_beds
)

select 	lpad(cast(facility_id as text),6,'0') as provider_ccn
		,to_date(start_date,'MM/DD/YYYY') AS converted_start_date
		,to_date(end_date,'MM/DD/YYYY') AS converted_end_date
		,hcahps.*
		,beds.number_of_beds
		,beds.fiscal_year_begin_date AS beds_start_report_period
		,beds.fiscal_year_end_date AS beds_end_report_period
		
from "postgres"."Hospital_Data".hcahps_data AS hcahps
left join hospital_beds_prep AS beds
	on lpad(cast(facility_id as text),6,'0') = beds.provider_ccn
	and beds.nth_row = 1