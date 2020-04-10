import pandas as pd
import itertools
import collections
import csv

output_csv = "simpson_connections.csv"

## Data read, sort and reindex
raw_data = pd.read_csv("simpsons_script_lines.csv", error_bad_lines=False)
raw_data = raw_data.sort_values("id").reset_index(drop=True)

## Unification of names to Title Case (some were UPPERCASE)
raw_data['raw_character_text'] = raw_data['raw_character_text'].str.title()

## Deletion of non important characters (characters with numbering
## indicate irrelevancy)
raw_data = raw_data.loc[
    raw_data['raw_character_text'].map(
        lambda x: '#' not in x, na_action="ignore"
    ).fillna(True)
]

## Deletion of characters that represent a group of people (we are not
## interested in crowds) - Words found in first iteration of subgroup
## discovery
exact_avoids =  [
     "All", "Kid", "Men",  "Man", "Children", "Interviewer", "Reporter"
]

partial_avoids = [
    'Activists', 'Adults', 'Announcer', 'Another',
    'Audience', 'Boy', 'Campers', 'Crowd', 'Employee', 'Everyone',
    'Girl', 'Guys', 'Hooligan', 'Kids', 'Man ', 'Movementarians',
    'Narrator', 'Nerds', 'Other', 'People', 'Quartet', 'Singer',
    'Student', 'Teacher', 'Thought', 'Voice', 'Waiter', 'Woman',
    'Women', 'Worker', '1St', '2Nd', "3Rd", "4Th", "5Th", "6Th"
]

raw_data = raw_data[
    raw_data['raw_character_text'].map(
        lambda x: pd.isna(x) or
        all([s not in x for s in partial_avoids])
    )
]

raw_data = raw_data[~raw_data['raw_character_text'].isin(exact_avoids)]

## Character list selection
character_list = raw_data['raw_character_text'].values

## Conversational groups (attending to scene change, character is nan
## on those lines)
conversation_groups = [list(set(x[1])) for x in itertools.groupby(
    character_list, lambda x: pd.isna(x)
) if not x[0]]

## Deletion of groups with one person
conversation_groups = [grp for grp in conversation_groups if len(grp) > 1]

## Order groups alphabetically
conversation_groups = list(map(sorted, conversation_groups))

pairs = list(map(lambda x: list(itertools.combinations(x, 2)),
                 conversation_groups))

pairs = [item for sublist in pairs for item in sublist]

counter = collections.Counter(pairs)

with open(output_csv, "w") as f:
    writer = csv.writer(f)
    writer.writerow(["source", "target", "weight"])

    for k, v in counter.items():
        writer.writerow([k[0], k[1], v])
