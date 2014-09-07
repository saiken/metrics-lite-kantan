package CheckStyleConfig;

sub getCheckStyleConfig {
    my $config = {
        max_sub_lines => {
            threshold => 60,
        },
        max_sub_mccabe_complexity => {
            threshold => 10,
        },
        max_file_number_of_tabs => {
            threshold => 1,
        },
    };

    return $config;
}

1
