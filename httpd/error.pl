# error handling routines for httpd.pl
# Marc VanHeyningen   March 1993


sub error {
    local($message) = @_;

    print NS '<TITLE>Error</TITLE><H1>Server Error</H1>', "\n";
    print NS $message, "\n";
    close NS;
    exit(-1);
}

1;
