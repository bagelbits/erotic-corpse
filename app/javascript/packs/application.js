import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import ReactOnRails from 'react-on-rails/client';
import App from 'components/App';
import 'channels';

Rails.start();
ActiveStorage.start();

ReactOnRails.register({ App });
