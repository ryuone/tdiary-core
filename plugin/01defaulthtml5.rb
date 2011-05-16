# -*- coding: utf-8 -*-
#
# define DOCTYPE
#
def doctype
	%Q[<!DOCTYPE html>]
end

#
# make navigation buttons
#
def navi
	result = %Q[<header class="adminmenu">\n]
	result << navi_user
	result << navi_admin
	result << %Q[</header>]
end

#
# default HTML header
#
@header_procs.shift
add_header_proc do
	calc_links
	<<-HEADER
	<meta charset="#{h charset}">
	<meta name="generator" content="tDiary #{h TDIARY_VERSION}">
	#{last_modified_header}
	#{content_script_type}
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{mobile_link_discovery}
	#{icon_tag}
	#{description_tag}
	#{jquery_tag.chomp}
	#{css_tag.chomp}
	#{iphone_tag.chomp}
	#{title_tag.chomp}
	#{robot_control.chomp}
	HEADER
end

if @html5plugin.nil? then
	module ::TDiary
		class TDiaryBase
			alias :_old_do_eval_rhtml :do_eval_rhtml

			protected
			def do_eval_rhtml( prefix )
				@rhtml      = "latest5.rhtml"  if @rhtml == "latest.rhtml"
				@rhtml      = "day5.rhtml"     if @rhtml == "day.rhtml"
				@rhtml      = "update5.rhtml"  if @rhtml == "update.rhtml"
				@footerfile = "footer5.rhtml"
				_old_do_eval_rhtml prefix
			end
		end

		module DiaryBase
			alias :_old_eval_rhtml :eval_rhtml
			def eval_rhtml( opt, path = '.' )
				ERB::new( File::open( "#{path}/skel/#{opt['prefix']}diary5.rhtml" ){|f| f.read }.untaint ).result( binding )
			end
		end

		class TdiaryDiary
			def to_html( opt = {}, mode = :HTML )
				case mode
				when :CHTML
					to_chtml( opt )
				else
					to_html5( opt )
				end
			end

			def to_html5( opt )
				r = ''
				each_section do |section|
					r << %Q[<article class="section">\n]
					r << %Q[<%= section_enter_proc( Time::at( #{date.to_i} ) ) %>\n]
					if section.subtitle then
						r << %Q[<h1><%= subtitle_proc( Time::at( #{date.to_i} ), #{section.subtitle.dump.gsub( /%/, '\\\\045' )} ) %></h1>\n]
					end
					if /^</ =~ section.body then
						r << %Q[#{section.body}]
					elsif section.subtitle
						r << %Q[<p>#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '')}.join( "</p>\n<p>" )}</p>\n]
					else
						r << %Q[<p><%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
						r << %Q[#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '' )}.join( "</p>\n<p>" )}</p>]
					end
					r << %Q[<%= section_leave_proc( Time::at( #{date.to_i} ) ) %>\n]
					r << %Q[</article>]
				end
				r
			end
		end
	end
end
@html5plugin = true

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

