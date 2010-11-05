use Plack::Builder;
use Log::Minimal;

builder {
  enable 'Log::Minimal';
  sub {
     debugf("debug");
     infof("info");
     warnf("warn");
     critf("crit");
     [200,['Content-Type'=>'text/plain'],['OK']];
  }
};



