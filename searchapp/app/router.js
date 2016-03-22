import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
    this.route('developments', { path: '/' }, function() {
      this.route('edit', { path: '/:development_id/edit' });
      this.route('search', { path: '/search' }, function() {
        this.route('map');
        this.route('table');
      });
    });
});

export default Router;
