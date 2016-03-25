import DS from 'ember-data';

export default DS.Model.extend({
  latitude: DS.attr("number"),
  longitude: DS.attr("number"),
  acres: DS.attr("number"),
  name: DS.attr("string"),
  address: DS.attr("string"),
  city: DS.attr("string"),
  commsf: DS.attr("string"),
  tothu: DS.attr("number"),
  year: DS.attr("number"),
  description: DS.attr("string"),
  walkscore: DS.attr("number"),
  location: function() {
    var longitude = this.get("longitude"),
    latitude = this.get("latitude");

     if (longitude && latitude) { return [longitude, latitude]; } else 
                                { return undefined; }
  }.property("latitude", "longitude"),
  refinedLat: DS.attr("string"),
  refinedLng: DS.attr("string"),
  teamMemberships: DS.hasMany("team-membership", { async: true }),
  developmentTeamMemberships: DS.hasMany("development-team-membership", { async: true })
});
