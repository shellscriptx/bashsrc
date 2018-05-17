#!/bin/bash
#
#    Copyright 2018 Juliano Santos [SHAMAN]
#
#    This file is part of bashsrc.
#
#    bashsrc is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    bashsrc is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with bashsrc.  If not, see <http://www.gnu.org/licenses/>.

[[ $__GTK_SH ]] && return 0

readonly __GTK_SH=1

source builtin.sh

# Dependência.
__DEP__[yad]='>= 0.38.0'

# widgets/objects
readonly -A __GTK_OBJECT=(
[gtk_button]=btn
[gtk_passwordbox]=h
[gtk_numberbox]=num
[gtk_editbox]=
[gtk_readonlybox]=ro
[gtk_checkbox]=chk
[gtk_combobox]=cb
[gtk_combobox_edit]=cbe
[gtk_entry_complete]=ce
[gtk_file_select]=fl
[gtk_files_select]=mfl
[gtk_file_create]=sfl
[gtk_dir_select]=dir
[gtk_dir_create]=cdir
[gtk_font_button]=fn
[gtk_date_button]=dt
[gtk_scale_button]=scl
[gtk_color_button]=clr
[gtk_toogle_button]=fbtn
[gtk_label]=lbl
[gtk_multiline_text]=txt
)

# estruturas
var gtk_t 		struct_t
var gtk_calendar_t 	struct_t
var gtk_window_t	struct_t
var gtk_color_t 	struct_t
var gtk_dnd_t 		struct_t
var gtk_entry_t 	struct_t
var gtk_file_t		struct_t
var gtk_font_t		struct_t
var gtk_form_t		struct_t

var gtk_field_t		struct_t

# field
gtk_field_t.__add__	caption		str 	\
			type		flag	\
			params		str

# geral
gtk_t.__add__	title			str 	\
		icon			file 	\
		width			uint 	\
		height			uint 	\
		posx			uint 	\
		posy			uint	\
		geometry		str	\
		timeout			uint	\
		timeout_indicator	flag	\
		text			str	\
		text_align		flag 	\
		image			file 	\
		image_on_top		bool 	\
		icon_theme		str 	\
		expander		str 	\
		button			str 	\
		no_buttons		bool 	\
		buttons_layout		flag	\
		no_markup		bool 	\
		no_escape		bool 	\
		borders			uint 	\
		always_print_result	bool 	\
		response		uint 	\
		selectable_labels	bool 	\
		sticky			bool 	\
		fixed			bool 	\
		on_top			bool 	\
		center			bool 	\
		mouse			bool 	\
		undecorated		bool 	\
		skip_taskbar		bool 	\
		maximized		bool 	\
		fullscreen		bool 	\
		no_focus		bool 	\
		close_on_unfocus	bool 	\
		splash			bool 	\
		plug			str 	\
		tabnum			uint 	\
		parent_win		str 	\
		kill_parent		flag 	\
		print_xid		bool

# formulário
gtk_window_t.__add__	window		gtk_t

# calendário
gtk_calendar_t.__add__	window		gtk_t	\
			day		uint 	\
			month		uint 	\
			year		uint 	\
			details		file 	\
			show_weeks	bool

# paleta de cores
gtk_color_t.__add__	window		gtk_t	\
			init_color	flag	\
			gtk_palette	bool	\
			palette		file	\
			expand_palette	bool	\
			mode		flag	\
			extra		bool	\
			alpha		bool

# caixa drag-n-grop
gtk_dnd_t.__add__	window		gtk_t

# caixa de entrada
gtk_entry_t.__add__	window		gtk_t 	\
			entry_label	str 	\
			entry_text	str 	\
			hide_text	str 	\
			completion	bool	\
			numeric		bool	\
			licon		str 	\
			licon_action	str 	\
			ricon		str 	\
			ricon_action	str

# caixa de seleção de arquivos
gtk_file_t.__add__	window			gtk_t	\
			directory		bool	\
			save			bool	\
			confirm_overwrite	str

# caixa de seleção de fontes
gtk_font_t.__add__	window		gtk_t 	\
			preview		str 	\
			separate_output	bool

# formulário
gtk_form_t.__add__	window		gtk_t		\
			field		gtk_field_t[]	\
			align		flag		\
			columns		uint		\
			scroll		bool		\
			output_by_row	bool		\
			focus_field	uint		\
			cycle_read	bool

function gtk.show()
{
	getopt.parse 1 "objname:var:+:$1" ${@:2}

	local objtype=$(__typeof__ $1)
	local object

	case $objtype in
		gtk_calendar_t)
			object='--calendar'

			local 	day=$($1.day)			\
				month=$($1.month)		\
				year=$($1.year)			\
				details=$($1.details)		\
				show_weeks=$($1.show_weeks)
				show_weeks=${show_weeks#false}
			;;
		gtk_color_t)
			object='--color'

			local	init_color=$($1.init_color) 		\
				gtk_palette=$($1.gtk_palette) 		\
				palette=$($1.palette) 			\
				expand_palette=$($1.expand_palette)	\
				mode=$($1.mode) 			\
				extra=$($1.extra) 			\
				alpha=$($1.alpha)
				gtk_palette=${gtk_palette#false}
				expand_palette=${expand_palette#false}
				extra=${extra#false}
				alpha=${alpha#false}
			;;
		gtk_entry_t)
			object='--entry'

			local	entry_label=$($1.entry_label)		\
				entry_text=$($1.entry_text) 	\
				hide_text=$($1.hide_text) 	\
				completion=$($1.completion) 	\
				numeric=$($1.numeric) 		\
				licon=$($1.licon)		\
				licon_action=$($1.licon_action) \
				ricon=$($1.ricon) 		\
				ricon_action=$($1.ricon_action)
				completion=${completion#false}
				numeric=${numeric#false}
		;;
		gtk_file_t)
			object='--file'

			local	directory=$($1.directory)	\
				save=$($1.save)			\
				confirm_overwrite=$($1.confirm_overwrite)
				directory=${directory#false}
				save=${save#false}
			;;
		gtk_font_t)
			object='--font'
					
			local	preview=$($1.preview) \
				separate_output=$($1.separate_output)
				separate_output=${separate_output#false}
			;;
		gtk_form_t)
			object='--form'

			local i	
			local	field=$($1.field)			\
				align=$($1.align)			\
				columns=$($1.columns)			\
				scroll=$($1.scroll)			\
				output_by_row=$($1.output_by_row) 	\
				focus_field=$($1.focus_field)		\
				cycle_read=$($1.cycle_read)
				scroll=${scroll#false}
				output_by_row=${output_by_row#false}
				cycle_read=${cycle_read#false}

			for ((i=0; i < $($field.__sizeof__); i++)); do
				fields+=("--field '$($field[$i].caption):${__GTK_OBJECT[$($field[$i].type)]}' '$($field[$i].params)'")
			done
			;;
					
		gtk_dnd_t)	object='--dnd';;
		gtk_window_t)	object='';;
		*)	error.trace def 'objname' "var" "$objtype" 'tipo do objeto inválido'; return $?;;
	esac

	local 	title=$($1.window.title)				\
		window_icon=$($1.window.icon)				\
		width=$($1.window.width) 				\
		height=$($1.window.height)				\
		posx=$($1.window.posx) 					\
		posy=$($1.window.posy)					\
		geometry=$($1.window.geometry)				\
		timeout=$($1.window.timeout)				\
		timeout_indicator=$($1.window.timeout_indicator)	\
		text=$($1.window.text)					\
		text_align=$($1.window.text_align)			\
		image=$($1.window.image)				\
		image_on_top=$($1.window.image_on_top)			\
		icon_theme=$($1.window.icon_theme)			\
		expander=$($1.window.expander)				\
		button=$($1.window.button)				\
		no_buttons=$($1.window.no_buttons)			\
		no_markup=$($1.window.no_markup)			\
		no_escape=$($1.window.no_escape)			\
		borders=$($1.window.borders)				\
		always_print_result=$($1.window.always_print_result)	\
		response=$($1.window.response) 				\
		selectable_labels=$($1.window.selectable_labels)	\
		sticky=$($1.window.sticky)				\
		fixed=$($1.window.fixed)				\
		on_top=$($1.window.on_top)				\
		center=$($1.window.center)				\
		mouse=$($1.window.mouse)				\
		undecorated=$($1.window.undecorated)			\
		skip_taskbar=$($1.window.skip_taskbar)			\
		maximized=$($1.window.maximized)			\
		fullscreen=$($1.window.fullscreen)			\
		no_focus=$($1.window.no_focus)				\
		close_on_unfocus=$($1.window.close_on_unfocus)		\
		splash=$($1.window.splash)				\
		plug=$($1.window.plug)					\
		tabnum=$($1.window.tabnum)				\
		parent_win=$($1.window.parent_win)			\
		kill_parent=$($1.window.kill_parent)			\
		print_xid=$($1.window.print_xid	)

	# opcional
	image_on_top=${image_on_top#false}
	no_buttons=${no_buttons#false}
	no_markup=${no_markup#false}
	no_escape=${no_scape#false}
	always_print_result=${always_print_result#false}
	selectable_labels=${selectable_labels#false}
	sticky=${sticky#false}
	fixed=${fixed#false}
	on_top=${on_top#false}
	mouse=${mouse#false}
	undecorated=${undecorated#false}
	skip_taskbar=${skip_taskbar#false}
	maximized=${maximized#false}
	fullscreen=${fullscreen#false}
	no_focus=${no_focus#false}
	close_on_unfocus=${close_on_unfocus#false}
	splash=${splash#false}
	print_xid=${print_xid#false}

	# inicializa objeto
	obj_parse="${title:+--title '$title'}
			${window_icon:+--window-icon '$window_icon'}
			${width:+--width '$width'}
			${height:+--height '$height'}
			${posx:+--posx '$posx'}
			${posy:+--posy '$posy'}
			${geometry:+--geometry '$geometry'}
			${maximized:+--maximized}
			${timeout:+--timeout '$timeout'}
			${timeout_indicator:+--timeout-indicator '$timeout_indicator'}
			${text:+--text '$text'}
			${text_align:+--text-align '$text_align'}
			${image:+--image '$image'}
			${image_on_top:+--image-on-top}
			${expander:+--expander '$expander'}
			${button:+--button \"${button//|/\" --button \"}\"}
			${no_buttons:+--no-buttons}
			${no_markup:+--no-markup}
			${no_scape:+--no-scape}
			${borders:+--borders '$borders'}
			${always_print_result:+--always-print-result}
			${response:+--response '$response'}
			${selectable_labels:+--selectable-labels}
			${sticky:+--sticky}
			${fixed:+--fixed}
			${on_top:+--on-top}
			${center:+--center}
			${mouse:+--mouse}
			${undecorated:+--undecorated}
			${skip_taskbar:+--skip-taskbar}
			${maximized:+--maximized}
			${fullscreen:+--fullscreen}
			${no_focus:+--no-focus}
			${close_on_unfocus:+--close-on-unfocus}
			${splash:+--splash}
			${plug:+--plug '$plug'}
			${tabnum:+--tabnum '$tabnum'}
			${parent_win:+--parent-win '$parent_win'}
			${kill_parent:+--kill-parent '$kill_parent'}
			${print_xid:+--print-xid}
			${day:+--day '$day'}
			${month:+--month '$month'}
			${year:+--year '$year'}
			${details:+--details '$details'}
			${show_weeks:+--show-weeks}
			${init_color:+--init-color '$init_color'}
			${gtk_palette:+--gtk-palette}
			${palette:+--palette '$palette'}
			${expand_palette:+--expand-palette}
			${mode:+--mode '$mode'}
			${extra:+--extra}
			${alpha:+--alpha}
			${entry_label:+--entry-label '$entry_label'}
			${entry_text:+--entry-text '$entry_text'}
			${hide_text:+--hide-text '$hide_text'}
			${completion:+--completion}
			${numeric:+--numeric}
			${licon:+--licon '$licon'}
			${licon_action:+--licon-action '$licon_action'}
			${ricon:+--ricon '$ricon'}
			${ricon_action:+--ricon-action '$ricon_action'}
			${preview:+--preview '$preview'}
			${separate_output:+--separate-output}
			${fields[@]}
			${align:+--align '$align'}
			${columns:+--columns '$columns'}
			${scroll:+--scroll}
			${output_by_row:+--output-by-row}
			${focus_field:+--focus-field '$focus_field'}
			${cycle_read:+--cycle-read}
			${object}"

		eval yad $obj_parse

		return $?
}

source.__INIT__
# /* __GTK_SH */
