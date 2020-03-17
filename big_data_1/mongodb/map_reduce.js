db.runCommand(
    { mapReduce: "restaurants",
      map : function Map() {
          var key = this.cuisine;
          emit(key, {
              "data":
              [
                  {
                      "name" : this.name,
                      "address": this.address,
                  }
              ]
          });
      },

      reduce : function Reduce(key, values) {
          var reduced = {"data":[]};
          for (var i in values) {

              var inter = values[i];
              for (var j in inter.data) {
                  reduced.data.push(inter.data[j]);
              }
          }
          return reduced;
      },

      finalize : function Finalize(key, reduced) {
          if (reduced.data.length == 1) {
              return {
                  "message" : "Sólo hay un restaurante para el tipo de cocina ".concat(key)
              };
          }
          var min_dist = 999999999999;
          var rest1 = { "name": "" };
          var rest2 = { "name": "" };
          var c1;
          var c2;
          var d;
          for (var i in reduced.data) {
              for (var j in reduced.data) {
                  if (i>=j) continue;
                  c1 = reduced.data[i];
                  c2 = reduced.data[j];
                  lat1 = c1.address.coord[0];
                  lon1 = c1.address.coord[1];
                  lat2 = c2.address.coord[0];
                  lon2 = c2.address.coord[1];
                  d = Math.pow(lat1 - lat2, 2) + Math.pow(lon1 - lon2, 2);
                  if (d < min_dist && d > 0) {
                      min_dist = d;
                      rest1 = c1;
                      rest2 = c2;
                  }
              }
          }
          return {
              "rest1": {"name": rest1.name, "address": rest1.address},
              "rest2": {"name": rest2.name, "address": rest2.address},
              "dist": Math.sqrt(min_dist),
              "Cuenta": reduced.data.length
          };
      },
      query : { "grades.score": { "$gte" : 7 } },
      out: { inline: 1 }
    });
