package Perl::Metrics::Lite::Kantan::Report::CheckStyle;
use strict;
use warnings;

use CheckStyleConfig;

sub new {
    my $class = shift;
    my $self = bless( {}, $class );

    my $configs = CheckStyleConfig->getCheckStyleConfig();

    for my $target (keys(%$configs) ){
        $self->{$target} = $configs->{$target}->{threshold};
    }

    return $self;
}

sub report {
    my ( $self, $analysis ) = @_;

    my $sub_stats      = $analysis->sub_stats;
    my $file_stats      = $analysis->file_stats;
    my $stats = _mergeSubAndFileStats( $sub_stats, $file_stats );
    my $checkstyle_xml = $self->create_checkstyle_xml($stats);

    print $checkstyle_xml;
}

sub create_checkstyle_xml {
    my ( $self, $stats ) = @_;
    my $xml = "";
    $xml .= "<checkstyle version=\"5.1\">\n";
    foreach my $file_path ( keys %{$stats} ) {
        my $sub_metrics = $stats->{$file_path};
        $xml .= $self->file_xml_fragment( $file_path, $sub_metrics );
    }
    $xml .= "</checkstyle>";
    return $xml;
}

sub file_xml_fragment {
    my ( $self, $file_path, $metrics ) = @_;

    my $xml = "";
    $xml .= "  <file name=\"${file_path}\"\>\n";
    foreach my $metric ( @{$metrics} ) {

        if( $metric->{is_file_metric} ){
            if ( $metric->{number_of_tabs} >= $self->{max_file_number_of_tabs} ) {
                $xml .= $self->file_number_of_tabs_xml_fragment($metric);
            }

        } else {

            if ( $metric->{lines} >= $self->{max_sub_lines} ) {
                $xml .= $self->sub_lines_xml_fragment($metric);
            }

            if ( $metric->{mccabe_complexity}
                >= $self->{max_sub_mccabe_complexity} )
            {
                $xml .= $self->sub_mccabe_complexity_xml_fragment($metric);
            }
        }
    }

    $xml .= "  </file>";
    $xml .= "\n";
    return $xml;
}

#### TODO ↓も動的に変換できるように修正する。 #####


sub sub_lines_xml_fragment {
    my ( $self, $sub_metric ) = @_;
    my $xml = "";
    $xml .= '    <error line="';
    $xml .= $sub_metric->{line_number};
    $xml .= '"';
    $xml .= ' column="1"';
    $xml .= ' severity="error"';
    $xml .= ' message="\'';
    $xml .= $sub_metric->{name};
    $xml .= '\' method length is ';
    $xml .= $sub_metric->{lines};
    $xml .= ' lines."';
    $xml
        .= ' source="com.puppycrawl.tools.checkstyle.checks.sizes.MethodLengthCheck"/>';
    $xml .= "\n";
    return $xml;
}

sub sub_mccabe_complexity_xml_fragment {
    my ( $self, $sub_metric ) = @_;

    my $xml = "";
    $xml .= '    <error line="';
    $xml .= $sub_metric->{line_number};
    $xml .= '"';
    $xml .= ' column="1"';
    $xml .= ' severity="error"';
    $xml .= ' message="\'';
    $xml .= $sub_metric->{name};
    $xml .= '\' method cyclomatic complexity is ';
    $xml .= $sub_metric->{mccabe_complexity};
    $xml .= '"';
    $xml
        .= ' source="com.puppycrawl.tools.checkstyle.checks.metrics.CyclomaticComplexityCheck"/>';
    $xml .= "\n";
    return $xml;
}

sub file_number_of_tabs_xml_fragment {
    my ( $self, $file_metric ) = @_;

    my $xml = "";
    $xml .= '    <error ';
    $xml .= ' column="1"';
    $xml .= ' severity="error"';
    $xml .= ' message="\'';
    $xml .= '\' tab count is ';
    $xml .= $file_metric->{number_of_tabs};
    $xml .= '"';
    $xml
        .= ' source="NumberOfTabsCheck"/>';
    $xml .= "\n";
    return $xml;
}

sub _mergeSubAndFileStats(){
    my ( $sub_stats, $file_stats ) = @_;

    # file_statsの結果をsub_statsにつめこむ
    for my $file (@$file_stats){
        $file->{main_stats}->{is_file_metric} = 1;
        push $sub_stats->{$file->{path}}, $file->{main_stats};
    }

    return $sub_stats;
}

1;

__END__
