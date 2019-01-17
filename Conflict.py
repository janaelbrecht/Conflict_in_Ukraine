import json 
import csv

All_conflicts_UKR = []

with open ('conflict_data/Ukraine.json', 'r') as file: 
    conflicts = json.load(file)
    for event in conflicts: 
        event["id"] = {
            'year': event["year"],
            'early estimate of date': event["date_start"],
            'late estimate of date': event["date_end"],
            'active year': event["active_year"],
            'type of violence': event["type_of_violence"],
            'conflict id new': event["conflict_new_id"],
            'conflict name': event["conflict_name"],
            'side a id': event["side_a_dset_id"],
            'side b id': event["side_b_dset_id"],
            'side a name': event["side_a"],
            'side b name': event["side_b"],
            'latitude': event["latitude"],
            'longitude': event["longitude"],
            'geom_wkt': event["geom_wkt"],
            'deaths side a': event["deaths_a"],
            'deaths side b': event["deaths_b"],
            'deaths civilians': event["deaths_civilians"],
            'deaths unknown': event["deaths_unknown"],
            'total deaths': event["best"]
        }
        All_conflicts_UKR.append(event["id"])

#print(All_conflicts_UKR)

header = []

for event in All_conflicts_UKR:
    for key in event.keys():
        if key not in header: 
            header.append(key)

with open ('Ukraine.csv', 'w') as file: 
    writer = csv.DictWriter(file, fieldnames=header, lineterminator='\n', delimiter=',')
    writer.writeheader()
    for event in All_conflicts_UKR:
        writer.writerow(event)


