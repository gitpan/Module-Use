# $Id: load.t,v 1.1 2002/04/19 15:34:05 jgsmith Exp $

BEGIN { print "1..1\n"; }

eval {
    use Module::Use ();
};

if($@) {
    print "not ok 1";
} else {
    print "ok     1";
}

1;
