// La mejor opcion:
resultado = db.runCommand(
    {
        "aggregate": "restaurants",
        "pipeline": [
            {$match: {"grades.score": {"$gte" : 7}}},
            {$group:
             {_id: "$cuisine",
              "rest1":{
                  $push: {
                      name: "$name",
                      address:"$address",
                  }
              },
              "rest2":{
                  $push: {
                      name: "$name",
                      address:"$address",
                  }
              }
             }
            },
            {$unwind: "$rest1"},
            {$unwind: "$rest2"},
            {$project: {
                _id: 0,
                cocina: "$_id",
                rest1: {name: "$rest1.name", address: "$rest1.address.street"},
                rest2: {name: "$rest2.name", address: "$rest2.address.street"},
                distancia:{
                    $sqrt: {
                        $sum:
                        [{$pow: [
                            {$subtract: [
                                {$arrayElemAt: ["$rest1.address.coord", 0]},
                                {$arrayElemAt: ["$rest2.address.coord", 0]}
                            ]}, 2
                        ]},
                         {$pow: [
                             {$subtract: [
                                 {$arrayElemAt: ["$rest1.address.coord", 1]},
                                 {$arrayElemAt: ["$rest2.address.coord", 1]}
                             ]}, 2
                         ]},
                        ]
                    }
                }
            }
            },
            {$redact: {"$cond":
                       [{$and:
                         [{"$lt": ["$rest1.name", "$rest2.name"]},
                          {"$ne":["$distancia",0.0]}] },"$$KEEP","$$PRUNE"]
                      }
            },
            {$group:
             {_id: "$cocina",
              "dist_min": {$min: "$distancia"},
              "parejas": {$push: {
                  rest1: "$rest1",
                  rest2: "$rest2",
                  distancia: "$distancia"
              }}
             }
            },
            {$unwind: "$parejas"},
            {$redact:
             {"$cond": [{"$eq": ["$dist_min", "$parejas.distancia"]},
                        "$$KEEP","$$PRUNE"]}
            },
            {$project:
             {_id: 0,
              "cocina": "$_id",
              "Restaurante1": "$parejas.rest1",
              "Restaurante2": "$parejas.rest2",
              "distancia": "$dist_min"
             }
            }
        ],
        "allowDiskUse": true,
        cursor: { batchSize: 100 }
    }
);
