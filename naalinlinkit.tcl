# Usage: Load the script in the config and on the partyline do: .chanset #channel +naalinlinkit

setudef flag naalinlinkit

bind pubm -|- "*" naalinlinkit::handler

namespace eval naalinlinkit {
proc handler {nick mask hand channel arguments} {

# Set desired filename here. It will be appended with year and .txt
set filenameheader "naalinlinkit"

set year [clock format [clock seconds] -format %Y]
set dbfile "${filenameheader}${year}.txt"
if {![file exists $dbfile]} { set txtfile [open $dbfile w]; close $txtfile }
set x $year
while {[file exists "${filenameheader}${x}.txt"]} { incr x -1 }
set inception [expr $x + 1]

if {[channel get $channel naalinlinkit] && [onchan $nick $channel]} {
	foreach item [split $arguments] {
	if {[string match -nocase "http://?*" $item] || [string match -nocase "www.?*" $item] || [string match -nocase "https://?*" $item]} {
		for {set x $inception} {$x <= $year} {incr x} {
			set txtfile [open "${filenameheader}${x}.txt" r+]
			while {![eof $txtfile]} {
				set urlfound false 
	                        set processline [gets $txtfile]
				if {[naalinlinkit::apinahandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::imgurhandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::kuvatonhandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::youtubehandler $item [lindex $processline 2]]} { set urlfound true }
        	                if {[string match -nocase $item [lindex $processline 2]]} {set urlfound true}
				if {$urlfound} {naalinlinkit::output $channel $processline}
	               	        unset processline
			}
			if {$x == $year} {puts $txtfile "[clock seconds] $nick $item"}
			close $txtfile
		}
	}
	unset item }
} }

proc output {channel outputtime} {
putquick "PRIVMSG $channel :w, [clock format [lindex $outputtime 0] -format "%D %H:%M"]"
}

proc apinahandler {url test} {
if {[naalinlinkit::getdomain $url] == "apina"} { set ying [regsub -all {[^0-9]} $url ""] }
if {[naalinlinkit::getdomain $test] == "apina"} { set yang [regsub -all {[^0-9]} $test ""] }
if {[naalinlinkit::getdomain $url] == "apcdn"} { set ying [regsub -all {[^0-9]} [lindex [split $url "/"] end] ""] }
if {[naalinlinkit::getdomain $test] == "apcdn"} { set yang [regsub -all {[^0-9]} [lindex [split $test "/"] end] ""] }
if {[info exists ying] && [info exists yang]} {
	if {[string match $ying $yang]} { return true } else {return false } } else { return false }
}

proc imgurhandler {url test} {
if {[naalinlinkit::getdomain $url] == "imgur"} {set ying [lindex [split [lindex [split $url "/"] end] .] 0]}
if {[naalinlinkit::getdomain $test] == "imgur"} {set yang [lindex [split [lindex [split $test "/"] end] .] 0]}
if {[info exists ying] && [info exists yang]} {
	if {[string match $ying $yang]} { return true } else { return false } } else { return false }
}

proc 4chanhandler {url test} {
set domains { 4chan kuvalauta lauta kotilauta northpole imagechan }
foreach item $domains {
	if {[string match $item [naalinlinkit::getdomain $url]} { 

	}
}
}

proc kuvatonhandler {url test} {
if {[naalinlinkit::getdomain $url] == "kuvaton"} {set ying [lindex [split [lindex [split $url "/"] end] .] 0]}
if {[naalinlinkit::getdomain $test] == "kuvaton"} {set yang [lindex [split [lindex [split $test "/"] end] .] 0]}
if {[info exists ying] && [info exists yang]} {
        if {[string match $ying $yang]} { return true } else { return false } } else { return false }
}

proc youtubehandler {url test} {
set urlfound false
if {[naalinlinkit::getdomain $url] == "youtube"} {
	foreach item [split [lindex [split $url "/"] end] "&"] {
                if {[string match [lindex [split [lindex [split $item "="] 0] "?"] 0] watch]} {
                        set ying [lindex [split [lindex [split $item "="] 1] "?"] 0] } }
}
if {[naalinlinkit::getdomain $test] == "youtube"} {
        foreach item [split [lindex [split $test "/"] end] "&"] {
                if {[string match [lindex [split [lindex [split $item "="] 0] "?"] 0] watch]} {
                        set yang [lindex [split [lindex [split $item "="] 1] "?"] 0] } }
}

if {[naalinlinkit::getdomain $url] == "youtu"} { set ying [lindex [split $url "/"] end] }
if {[naalinlinkit::getdomain $test] == "youtu"} { set yang [lindex [split $test "/"] end] }

if {[info exists ying] && [info exists yang]} {
        if {[string match $ying $yang]} {return true } else {return false} } else {return false }
}

proc getdomain {url} {
if {[string tolower [string index $url 0]] == "w"} { return [lindex [split [lindex [split $url "/"] 0] .] end-1] }
if {[string tolower [string index $url 0]] == "h"} { return [lindex [split [lindex [split $url "//"] 2] .] end-1] }
}

}

putlog "Naalinlinkit V2.0 by T-101"
