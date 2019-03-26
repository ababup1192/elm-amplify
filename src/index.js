'use strict';
import { environment } from './environments'
import Amplify, { Auth } from 'aws-amplify';
import { Observable, from, of } from 'rxjs';
import * as axios from 'axios';

require("./styles.scss");

const {Elm} = require('./Main');
var app = Elm.Main.init();

Amplify.configure(environment.amplify);

from(Auth.signIn('user', 'pass')).subscribe(signIn => {
  const instance = axios.create({
    baseURL: environment.apiBaseUrl,
    headers: {
      'Authorization': signIn.signInUserSession.idToken.jwtToken
    }
  });
  instance.get('/pets').then(response =>
    console.log(response)
  ).catch(error =>
    console.log(error)
  );
});
