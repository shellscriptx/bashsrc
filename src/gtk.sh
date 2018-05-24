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

declare -A __GTK_WIDGET_OBJ_INIT

readonly -a __GTK_OBJECT=(
gtk_calendar_t
gtk_color_t
gtk_dnd_t
gtk_entry_t
gtk_file_t
gtk_font_t
gtk_form_t
gtk_icons_t
gtk_list_t
gtk_multi_progress_t
gtk_picture_t
gtk_print_t
gtk_progress_t
gtk_scale_t
gtk_text_info_t
)

# widgets/objects
readonly -A __GTK_WIDGET_FLAG=(
[gtk_button]=BTN
[gtk_passwordbox]=H
[gtk_spin_button]=NUM
[gtk_entry]=
[gtk_readonlybox]=RO
[gtk_checkbox]=CHK
[gtk_combobox]=CB
[gtk_combobox_edit]=CBE
[gtk_entry_complete]=CE
[gtk_file_select]=FL
[gtk_files_select]=MFL
[gtk_file_create]=SFL
[gtk_dir_select]=DIR
[gtk_dir_create]=CDIR
[gtk_font_button]=FN
[gtk_date_button]=DT
[gtk_scale_button]=SCL
[gtk_color_button]=CLR
[gtk_toogle_button]=FBTN
[gtk_label]=LBL
[gtk_textbox]=TXT
)

readonly -A __GTK_WIDGET_COLUMN_TYPE=(
[gtk_widget_column_text]=TEXT
[gtk_widget_column_number]=NUM
[gtk_widget_column_size]=SZ
[gtk_widget_column_float]=FLT
[gtk_widget_column_checkbox]=CHK
[gtk_widget_column_radiobox]=RD
[gtk_widget_column_progressbar]=BAR
[gtk_widget_column_hide]=HD
[gtk_widget_column_tooltip]=TIP
)

readonly -A __GTK_WIDGET_BAR_TYPE=(
[gtk_widget_bar_normal]=NORM
[gtk_widget_bar_reverse]=RTL
[gtk_widget_bar_pulse]=PULSE
)

# Objetos
var gtk_widget_t		struct_t
var gtk_widget_column_t		struct_t
var gtk_widget_button_t		struct_t
var gtk_widget_bar_t		struct_t
var gtk_window_t		struct_t
var gtk_calendar_t 		struct_t
var gtk_color_t 		struct_t
var gtk_dnd_t 			struct_t
var gtk_entry_t 		struct_t
var gtk_file_t			struct_t
var gtk_font_t			struct_t
var gtk_form_t			struct_t
var gtk_icons_t			struct_t
var gtk_list_t			struct_t
var gtk_multi_progress_t	struct_t
var gtk_picture_t		struct_t
var gtk_print_t			struct_t
var gtk_progress_t		struct_t
var gtk_scale_t			struct_t
var gtk_text_info_t		struct_t

# widget
gtk_widget_t.__add__	type		flag 			\
			label		str			\
			icon		str			\
			tooltip		str			\
			id		uint 			\
			value		str			\
			exec		str			\
			callback	uint			\
			widget_call	var

# botão
gtk_widget_button_t.__add__	label		str	\
				tooltip		str	\
				icon		str	\
				id		uint
# coluna
gtk_widget_column_t.__add__	type	flag	\
				label	str

gtk_widget_bar_t.__add__	type	flag	\
				label	str

# Configurações gerais.
gtk_window_t.__add__	title			str 			\
			icon			file 			\
			width			uint 			\
			height			uint 			\
			posx			uint 			\
			posy			uint			\
			geometry		str			\
			timeout			uint			\
			timeout_indicator	flag			\
			text			str			\
			text_align		flag 			\
			image			file 			\
			image_on_top		bool 			\
			icon_theme		str 			\
			expander		str 			\
			button			gtk_widget_button_t[] 	\
			no_buttons		bool 			\
			buttons_layout		flag			\
			no_markup		bool 			\
			no_escape		bool 			\
			borders			uint 			\
			always_print_result	bool 			\
			response		uint 			\
			selectable_labels	bool 			\
			sticky			bool 			\
			fixed			bool 			\
			on_top			bool 			\
			center			bool 			\
			mouse			bool 			\
			undecorated		bool 			\
			skip_taskbar		bool 			\
			maximized		bool 			\
			fullscreen		bool 			\
			no_focus		bool 			\
			close_on_unfocus	bool 			\
			splash			bool 			\
			plug			str 			\
			tabnum			uint 			\
			parent_win		str 			\
			kill_parent		flag 			\
			print_xid		bool			\
			stdout			str			\
			stderr			str

# calendário
gtk_calendar_t.__add__	window		gtk_window_t	\
			day		uint 		\
			month		uint 		\
			year		uint 		\
			details		file 		\
			show_weeks	bool

# paleta de cores
gtk_color_t.__add__	window		gtk_window_t	\
			init_color	str		\
			gtk_palette	bool		\
			palette		file		\
			expand_palette	bool		\
			mode		flag		\
			extra		bool		\
			alpha		bool

# caixa drag-n-grop
gtk_dnd_t.__add__	window		gtk_window_t	\
			tooltip		bool		\
			command		str

# caixa de entrada
gtk_entry_t.__add__	window		gtk_window_t 	\
			entry_label	str 		\
			entry_text	str 		\
			hide_text	str	 	\
			completion	bool		\
			numeric		bool		\
			licon		str 		\
			licon_action	str 		\
			ricon		str 		\
			ricon_action	str		\
			num_output	bool

# caixa de seleção de arquivos
gtk_file_t.__add__	window			gtk_window_t	\
			filename		str		\
			multiple		bool		\
			directory		bool		\
			save			bool		\
			separator		str		\
			quoted_output		bool		\
			confirm_overwrite	str

# caixa de seleção de fontes
gtk_font_t.__add__	window		gtk_window_t 	\
			fontname	str		\
			preview		str 		\
			separate_output	bool		\
			separator	str		\
			quoted_output	bool

# formulário
gtk_form_t.__add__	window		gtk_window_t	\
			widget		gtk_widget_t[]	\
			align		flag		\
			columns		uint		\
			separator	str		\
			item_separator	str		\
			date_format	str		\
			float_precision	uint		\
			complete	flag		\
			scroll		bool		\
			output_by_row	bool		\
			focus_field	uint		\
			cycle_read	bool		\
			quoted_output	bool		\
			num_output	bool

# icones
gtk_icons_t.__add__	window		gtk_window_t	\
			read_dir	path		\
			compact		bool		\
			generic		bool		\
			item_width	uint		\
			term		str		\
			sort_by_name	bool		\
			descend		bool		\
			single_click	bool		\
			listen		bool		\
			monitor		bool

# lista
gtk_list_t.__add__	window		gtk_window_t		\
			columns		gtk_widget_column_t[]	\
			checklist	bool			\
			radiolist	bool			\
			no_headers	bool			\
			no_click	bool			\
			no_rules_hint	bool			\
			grid_lines	flag			\
			print_all	bool			\
			editable_cols	str			\
			wrap_width	uint			\
			wrap_cols	str			\
			ellipsize	flag			\
			ellipsize_cols	str			\
			print_column	uint			\
			hide_column	uint			\
			expand_column	uint			\
			search_column	uint			\
			tooltip_column	uint			\
			sep_column	uint			\
			sep_value	str			\
			limit		uint			\
			dclick_action	str			\
			select_action	str			\
			add_action	str			\
			regex_search	str			\
			no_selection	bool			\
			value		str

# Barras de progresso
gtk_multi_progress_t.__add__	window		gtk_window_t		\
				bar		gtk_widget_bar_t[] 	\
				watch_bar	uint			\
				align		flag			\
				auto_close	bool			\
				auto_kill	bool

# Foto
gtk_picture_t.__add__		window		gtk_window_t	\
				size		flag		\
				inc		uint		\
				filename	file

# Caixa de dialog de impressão
gtk_print_t.__add__		window		gtk_window_t	\
				type		flag		\
				headers		bool		\
				add_preview	bool		\
				filename	file		\
				fontname	str
				
# Caixa de progresso
gtk_progress_t.__add__		window		gtk_window_t	\
				progress_text	str		\
				percentage	uint		\
				rtl		bool		\
				auto_close	bool		\
				auto_kill	bool		\
				pulsate		bool		\
				enable_log	str		\
				log_on_top	bool		\
				log_expanded	bool		\
				log_height	uint
				

# Escala
gtk_scale_t.__add__		window		gtk_window_t	\
				value		uint		\
				min_value	uint		\
				max_value	uint		\
				step		uint		\
				page		uint		\
				print_partial	bool		\
				hide_value	bool		\
				invert		bool		\
				inc_buttons	bool		\
				mark		str		

# Texto informativo
gtk_text_info_t.__add__		window		gtk_window_t	\
				filename	file		\
				editable	bool		\
				fore		flag		\
				back		flag		\
				fontname	str		\
				wrap		bool		\
				justify		flag		\
				margins		uint		\
				tail		bool		\
				show_cursor	bool		\
				show_uri	bool		\
				uri_color	flag		\
				lang		flag		\
				listen		bool

# func gtk.init <[var]gtk_object> ... => [bool]
#
# Inicializa o objeto apontado por 'gtk_object'.
# Obs: Pode ser especificado um ou mais objetos.
#
function gtk.init()
{
	getopt.parse -1 "gtk_object:var:+:$1" ... "$@"

	local objtype object gtk_object

	for gtk_object in "$@"; do
		local 	objtype=$(__typeof__ $gtk_object)
		local	object				

		case $objtype in
			gtk_calendar_t)
				object='calendar'

				local 	day=$($gtk_object.day)			\
					month=$($gtk_object.month)		\
					year=$($gtk_object.year)		\
					details=$($gtk_object.details)		\
					show_weeks=$($gtk_object.show_weeks)
					show_weeks=${show_weeks#false}
				;;
			gtk_color_t)
				object='color'
	
				local	init_color=$($gtk_object.init_color) 		\
					gtk_palette=$($gtk_object.gtk_palette) 		\
					palette=$($gtk_object.palette) 			\
					expand_palette=$($gtk_object.expand_palette)	\
					mode=$($gtk_object.mode) 			\
					extra=$($gtk_object.extra) 			\
					alpha=$($gtk_object.alpha)
					gtk_palette=${gtk_palette#false}
					expand_palette=${expand_palette#false}
					extra=${extra#false}
					alpha=${alpha#false}
				;;
			gtk_entry_t)
				object='entry'
	
				local	entry_label=$($gtk_object.entry_label)		\
					entry_text=$($gtk_object.entry_text) 		\
					hide_text=$($gtk_object.hide_text) 		\
					completion=$($gtk_object.completion) 		\
					numeric=$($gtk_object.numeric) 			\
					licon=$($gtk_object.licon)			\
					licon_action=$($gtk_object.licon_action) 	\
					ricon=$($gtk_object.ricon) 			\
					ricon_action=$($gtk_object.ricon_action) 	\
					num_output=$($gtk_object.num_output)
					completion=${completion#false}
					numeric=${numeric#false}
					num_output=${num_output#false}
					entry_text=${entry_text//\!/\' \'}
			;;
			gtk_file_t)
				object='file'
	
				local	filename=$($gtk_object.filename)			\
					multiple=$($gtk_object.multiple)			\
					directory=$($gtk_object.directory)			\
					save=$($gtk_object.save)				\
					separator=$($gtk_object.separator)			\
					confirm_overwrite=$($gtk_object.confirm_overwrite)	\
					quoted_output=$($gtk_object.quoted_output)
					multiple=${multiple#false}
					directory=${directory#false}
					save=${save#false}
					quoted_output=${quoted_output#false}
				;;
			gtk_font_t)
				object='font'
						
				local	fontname=$($gtk_object.fontname)		\
					preview=$($gtk_object.preview) 			\
					separate_output=$($gtk_object.separate_output)	\
					separator=$($gtk_object.separator)		\
					quoted_output=$($gtk_object.quoted_output)
					separate_output=${separate_output#false}
					quoted_output=${quoted_output#false}
				;;
			gtk_form_t)
				object='form'
	
				local	obj=$($gtk_object.widget)			\
					align=$($gtk_object.align)			\
					columns=$($gtk_object.columns)			\
					separator=$($gtk_object.separator)		\
					item_separator=$($gtk_object.item_separator)	\
					date_format=$($gtk_object.date_format)		\
					float_precision=$($gtk_object.float_precision)	\
					complete=$($gtk_object.complete)		\
					quoted_output=$($gtk_object.quoted_output)	\
					scroll=$($gtk_object.scroll)			\
					output_by_row=$($gtk_object.output_by_row) 	\
					num_output=$($gtk_object.num_output)		\
					focus_field=$($gtk_object.focus_field)		\
					cycle_read=$($gtk_object.cycle_read)		
					scroll=${scroll#false}
					output_by_row=${output_by_row#false}
					cycle_read=${cycle_read#false}
					num_output=${num_output#false}
					quoted_output=${quoted_output#false}
				
				if [[ $obj ]]; then
					local 	widgets=${!__GTK_WIDGET_FLAG[@]}
					local 	widget callback fields widget_call widget_call_type exec objects i
					for ((i=0; i < $($obj.__sizeof__); i++)); do
						widget=$($obj[$i].type)
						callback=$($obj[$i].callback)
						widget_call=$($obj[$i].widget_call)
						exec=$($obj[$i].exec)
						
						if [[ $widget_call ]]; then
							objects=${__GTK_OBJECT[@]}
							widget_call_type=$(__typeof__ $widget_call)
							if [[ $widget_call_type != @(${objects// /|}) ]]; then
								error.trace def 'widget_call' 'var' "$widget_call" "'${widget_call_type:-null}' widget inválido"
								return $?
							fi						
						fi

						if [[ $widget != @(${widgets[@]// /|}) ]]; then
							error.trace def 'widget' 'gtk_widget_t' "$widget" "$obj[$i]: objeto widget inválido"
							return $?
						elif [[ $widget == @(gtk_button|gtk_toogle_button) ]]; then
							fields[$i]="--field '$($obj[$i].label)"'!'"$($obj[$i].icon)"'!'"$($obj[$i].tooltip):${__GTK_WIDGET_FLAG[$widget]}' \"${callback:+@echo ${callback}:\$(}bash -c '${exec:+$exec;}${widget_call:+yad ${__GTK_WIDGET_OBJ_INIT[$widget_call]//\'/\\\"}}'${callback:+)}\""
						else
							fields[$i]="--field '$($obj[$i].label):${__GTK_WIDGET_FLAG[$widget]}' '$($obj[$i].value)'"
						fi
					done
				fi
				;;
			gtk_icons_t)
				object='icons'
				
				local	read_dir=$($gtk_object.read_dir)		\
					compact=$($gtk_object.compact)			\
					generic=$($gtk_object.generic)			\
					item_width=$($gtk_object.item_width)		\
					term=$($gtk_object.term)			\
					sort_by_name=$($gtk_object.sort_by_name)	\
					descend=$($gtk_object.descend)			\
					single_click=$($gtk_object.single_click)	\
					monitor=$($gtk_object.monitor)			\
					listen=$($gtk_object.listen)
					compact=${compact#false}
					generic=${generic#false}
					sort_by_name=${sort_by_name#false}
					descend=${descend#false}
					single_click=${single_click#false}
					monitor=${monitor#false}
					listen=${listen#false}
				;;
			gtk_list_t)
				object='list'
				
				local	column=$($gtk_object.columns)			\
					checklist=$($gtk_object.checklist)		\
					radiolist=$($gtk_object.radiolist)		\
					no_headers=$($gtk_object.no_headers)		\
					no_click=$($gtk_object.no_click)		\
					no_rules_hint=($gtk_object.no_rules_hint)	\
					grid_lines=$($gtk_object.grid_lines)		\
					print_all=$($gtk_object.print_all)		\
					editable_cols=$($gtk_object.editable_cols)	\
					wrap_width=$($gtk_object.wrap_width)		\
					wrap_cols=$($gtk_object.wrap_cols)		\
					ellipsize=$($gtk_object.ellipsize)		\
					ellipsize_cols=$($gtk_object.ellipsize_cols)	\
					print_column=$($gtk_object.print_column)	\
					hide_column=$($gtk_object.hide_column)		\
					expand_column=$($gtk_object.expand_column)	\
					search_column=$($gtk_object.search_column)	\
					tooltip_column=$($gtk_object.tooltip_column)	\
					sep_column=$($gtk_object.sep_column)		\
					sep_value=$($gtk_object.sep_value)		\
					limit=$($gtk_object.limit)			\
					dclick_action=$($gtk_object.dclick_action)	\
					select_action=$($gtk_object.select_action)	\
					add_action=$($gtk_object.add_action)		\
					regex_search=$($gtk_object.regex_search)	\
					no_selection=$($gtk_object.no_selection)	\
					lstvalue=$($gtk_object.value)
					lstvalue="'${lstvalue//\!/\' \'}'"
					checklist=${checklist#false}
					radiolist=${radiolist#false}
					no_headers=${no_headers#false}
					no_click=${no_click#false}
					no_rules_hint=${no_rules_hint#false}
					print_all=${print_all#false}
					regex_search=${regex_search#false}
					no_selection=${no_selection#false}
	
					if [[ $column ]]; then
						local col_types=${!__GTK_WIDGET_COLUMN_TYPE[@]}
						local lstcolumns col_type i
						for ((i=0; i < $($column.__sizeof__); i++)); do
							col_type=$($column[$i].type)
							if [[ $col_type == @(${col_types[@]// /|}) ]]; then
								lstcolumns[$i]="--column '$($column[$i].label):${__GTK_WIDGET_COLUMN_TYPE[$col_type]}'"
							else
								error.trace def 'column' 'gtk_widget_column_t' "$col_type" "$column[$i]: tipo da coluna inválida	"
								return $?
							fi
						done
					fi
				;;
			gtk_multi_progress_t)
					object='multi-progress'
					
					local	bar=$($gtk_object.bar)			\
						watch_bar=$($gtk_object.watch_bar)	\
						align=$($gtk_object.align)		\
						auto_close=$($gtk_object.auto_close)	\
						auto_kill=$($gtk_object.auto_kill)
						auto_close=${auto_close#false}
						auto_kill=${auto_kill#false}
	
					if [[ $bar ]]; then
						local bar_types=${!__GTK_WIDGET_BAR_TYPE[@]}
						local bars bar_type i
						for ((i=0; i < $($bar.__sizeof__); i++)); do
							bar_type=$($bar[$i].type)
							if [[ $bar_type == @(${bar_types[@]// /|}) ]]; then
							bars[$i]="--bar '$($bar[$i].label):${__GTK_WIDGET_BAR_TYPE[$bar_type]}'"
						else
							error.trace def 'bar' 'gtk_widget_bar_t' "$bar_type" "$bar[$i]: tipo da barra de progresso inválida"
							return $?
						fi
						done
					fi
				;;
			gtk_picture_t)
					object='picture'
					
					local	size=$($gtk_object.size)		\
						inc=$($gtk_object.inc)			\
						filename=$($gtk_object.filename)
				;;
			gtk_print_t)
					object='print'
					
					local	type=$($gtk_object.type)			\
						headers=$($gtk_object.headers)			\
						add_preview=$($gtk_object.add_preview)		\
						filename=$($gtk_object.filename)		\
						fontname=$($gtk_object.fontname)
						headers=${headers#false}
						add_preview=${add_preview#false}
				;;
			gtk_progress_t)
					object='progress'
					
					local	progress_text=$($gtk_object.progress_text)	\
						percentage=$($gtk_object.percentage)		\
						pulsate=$($gtk_object.pulsate)			\
						auto_close=$($gtk_object.auto_close)		\
						auto_kill=$($gtk_object.auto_kill)		\
						rtl=$($gtk_object.rtl)				\
						enable_log=$($gtk_object.enable_log)		\
						log_expanded=$($gtk_object.log_expanded)	\
						log_on_top=$($gtk_object.log_on_top)		\
						log_height=$($gtk_object.log_height)
						pulsate=${pulsate#false}
						auto_close=${auto_close#false}
						auto_kill=${auto_kill#false}
						rtl=${rtl#false}
						log_expanded=${log_expanded#false}
						log_on_top=${log_on_top#false}
				;;
			gtk_scale_t)
					object='scale'
					
					local	value=$($gtk_object.value)			\
						min_value=$($gtk_object.min_value)		\
						max_value=$($gtk_object.max_value)		\
						step=$($gtk_object.step)			\
						page=$($gtk_object.page)			\
						print_partial=$($gtk_object.print_partial)	\
						hide_value=$($gtk_object.hide_value)		\
						invert=$($gtk_object.invert)			\
						inc_buttons=$($gtk_object.inc_buttons)		\
						mark=$($gtk_object.mark)
						print_partial=${print_partial#false}
						hide_value=${hide_value#false}
						invert=${invert#false}
						inc_buttons=${inc_buttons#false}
						mark=${mark:+--mark \'${mark//\!/\' --mark \'}\'}
						;;
			gtk_text_info_t)
					object='text-info'
					
					local	filename=$($gtk_object.filename)		\
						editable=$($gtk_object.editable)		\
						fore=$($gtk_object.fore)			\
						back=$($gtk_object.back)			\
						fontname=$($gtk_object.fontname)		\
						wrap=$($gtk_object.wrap)			\
						justify=$($gtk_object.justify)		\
						margins=$($gtk_object.margins)		\
						tail=$($gtk_object.tail)			\
						show_cursor=$($gtk_object.show_cursor)	\
						show_uri=$($gtk_object.show_uri)		\
						uri_color=$($gtk_object.uri_color)	\
						lang=$($gtk_object.lang)			\
						listen=$($gtk_object.listen)
						editable=${editable#false}
						wrap=${wrap#false}
						tail=${tail#false}
						show_cursor=${show_cursor#false}
						show_uri=${show_uri#false}
						listen=${listen#false}
				;;
			gtk_dnd_t)
					object='dnd'
					
					local	tooltip=$($gtk_object.tooltip)	\
						command=$($gtk_object.command)
						tooltip=${tooltip#false}
				;;
			*)	error.trace def 'gtk_object' 'var' "$gtk_object" "'${objtype:-null}' tipo do objeto inválido"; return $?;;
		esac
	
		local 	title=$($gtk_object.window.title)				\
			window_icon=$($gtk_object.window.icon)				\
			width=$($gtk_object.window.width) 				\
			height=$($gtk_object.window.height)				\
			posx=$($gtk_object.window.posx) 					\
			posy=$($gtk_object.window.posy)					\
			geometry=$($gtk_object.window.geometry)				\
			timeout=$($gtk_object.window.timeout)				\
			timeout_indicator=$($gtk_object.window.timeout_indicator)	\
			text=$($gtk_object.window.text)					\
			text_align=$($gtk_object.window.text_align)			\
			image=$($gtk_object.window.image)				\
			image_on_top=$($gtk_object.window.image_on_top)			\
			icon_theme=$($gtk_object.window.icon_theme)			\
			expander=$($gtk_object.window.expander)				\
			button=$($gtk_object.window.button)				\
			no_buttons=$($gtk_object.window.no_buttons)			\
			no_markup=$($gtk_object.window.no_markup)			\
			no_escape=$($gtk_object.window.no_escape)			\
			borders=$($gtk_object.window.borders)				\
			always_print_result=$($gtk_object.window.always_print_result)	\
			response=$($gtk_object.window.response) 				\
			selectable_labels=$($gtk_object.window.selectable_labels)	\
			sticky=$($gtk_object.window.sticky)				\
			fixed=$($gtk_object.window.fixed)				\
			on_top=$($gtk_object.window.on_top)				\
			center=$($gtk_object.window.center)				\
			mouse=$($gtk_object.window.mouse)				\
			undecorated=$($gtk_object.window.undecorated)			\
			skip_taskbar=$($gtk_object.window.skip_taskbar)			\
			maximized=$($gtk_object.window.maximized)			\
			fullscreen=$($gtk_object.window.fullscreen)			\
			no_focus=$($gtk_object.window.no_focus)				\
			close_on_unfocus=$($gtk_object.window.close_on_unfocus)		\
			splash=$($gtk_object.window.splash)				\
			plug=$($gtk_object.window.plug)					\
			tabnum=$($gtk_object.window.tabnum)				\
			parent_win=$($gtk_object.window.parent_win)			\
			kill_parent=$($gtk_object.window.kill_parent)			\
			print_xid=$($gtk_object.window.print_xid	)			\
			stdout=$($gtk_object.window.stdout)				\
			stderr=$($gtk_object.window.stderr)
	
		# Opcional
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
	
		if [[ $button ]]; then
			local 	buttons
			for ((i=0; i < $($button.__sizeof__); i++)); do
				buttons[$i]="--button '$($button[$i].label)"'!'"$($button[$i].icon)"'!'"$($button[$i].tooltip):$($button[$i].id)'"
			done
		fi
	
		# config
		__GTK_WIDGET_OBJ_INIT[$gtk_object]="
			${object:+--$object}
			${title:+--title '$title'}
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
			${buttons[@]}
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
			${num_output:+--num-output}
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
			${item_separator:+--item-separator '$item_separator'}
			${date_format:+--date-format '$date_format'}
			${float_precision:+--float-precision '$float_precision'}
			${complete:+--complete '$complete'}
			${read_dir:+--read-dir '$read_dir'}
			${compact:+--compact}
			${generic:+--generic}
			${item_width:+--item-width '$item_width'}
			${term:+--term '$term'}
			${sort_by_name:+--sort-by-name}
			${descend:+--descend}
			${single_click:+--single-click}
			${monitor:+--monitor}
			${checklist:+--checklist}
			${radiolist:+--radiolist}
			${no_headers:+--no-headers}
			${no_click:+--no-click}
			${no_rules_hint:+--no-rules-hint}
			${grid_lines:+--grid-lines '$grid_lines'}
			${print_all:+--print-all}
			${editable_cols:+--editable-cols '$editable_cols'}
			${wrap_width:+--wrap-width '$wrap_width'}
			${wrap_cols:+--wrap-cols '$wrap_cols'}
			${ellipsize:+--ellipsize '$ellipsize'}
			${ellipsize_cols:+--sllipsize-cols '$ellipsize_cols'}
			${print_column:+--print-column '$print_column'}
			${hide_column:+--hide-column '$hide_column'}
			${expand_column:+--expand-column '$expand_column'}
			${search_column:+--search-column '$search_column'}
			${tooltip_column:+--tooltip-column '$tooltip_column'}
			${sep_column:+--sep-column '$sep_column'}
			${sep_value:+--sep-value '$sep_value'}
			${limit:+--limit '$limit'}
			${dclick_action:+--dclick-action '$dclick_action'}
			${select_action:+--select-action '$select_action'}
			${add_action:+--add-action '$add_action'}
			${regex_search:+--regex-search}
			${no_selection:+--no-selection}
			${lstcolumns[@]}
			${lstvalue}
			${bars[@]}
			${watch_bar:+--watch-bar '$watch_bar'}
			${auto_close:+--auto-close}
			${auto_kill:+--auto-kill}
			${tab:+--tab '$tab'}
			${tab_pos:+--tab-pos '$tab_pos'}
			${tab_borders:+--tab-borders '$tab_borders'}
			${size:+--size '$size'}
			${inc:+--inc '$inc'}
			${filename:+--filename '$filename'}
			${type:+--type '$type'}
			${headers:+--headers}
			${add_preview:+--add-preview}
			${fontname:+--fontname '$fontname'}
			${progress_text:+--progress-text '$progress_text'}
			${percentage:+--percentage '$percentage'}
			${pulsate:+--pulsate}
			${rtl:+--rtl}
			${enable_log:+--enable-log  '$enable_log'}
			${log_expanded:+--log-expanded}
			${log_on_top:+--log-on-top}
			${log_height:+--log-height '$log_height'}
			${value:+--value '$value'}
			${min_value:+--min-value '$min_value'}
			${max_value:+--max-value '$max_value'}
			${step:+--step	'$step'}
			${page:+--page '$page'}
			${print_partial:+--print-partial}
			${hide_value:+--hide-value}
			${invert:+--invert}
			${inc_buttons:+--inc-buttons}
			${mark}
			${editable:+--editable}
			${fore:+--fore '$fore'}
			${back:+--back '$back'}
			${wrap:+--wrap}
			${justify:+--justify '$justify'}
			${margins:+--margins '$margins'}
			${tail:+--tail}
			${show_cursor:+--show-cursor}
			${show_uri:+--show-uri}
			${uri_color:+--uri-color '$uri_color'}
			${lang:+--lang '$lang'}
			${listen:+--listen}
			${tooltip:+--tooltip '$tooltip'}
			${command:+--command '$command'}
			${multiple:+--multiple}
			${directory:+--directory}
			${save:+--save}
			${separator:+--separator '$separator'}
			${confirm_overwrite:+--confirm-overwrite '$confirm_overwrite'}
			${quoted_output:+--quoted-output}
			${stdout:+1> '$output'}
			${stderr:+2> '$stderr'}"
	done

	return $?
}

# func gtk.show <[var]gtk_object> => [bool]
#
# Exibe o objeto apontado por 'gtk_object'
#
function gtk.show()
{
	getopt.parse 1 "gtk_object:var:+:$1" ${@:2}

	local objtype=$(__typeof__ $1)
	local objects=${__GTK_OBJECT[@]}

	if [[ $objtype != @(${objects// /|}) ]]; then
		error.trace def 'gtk_object' 'var' "$1" "'${objtype:-null}' tipo do objeto inválido"
		return $?
	elif [[ ! ${__GTK_WIDGET_OBJ_INIT[$1]} ]]; then
		error.trace def 'gtk_object' 'var' "$1" 'o objeto não foi inicializado'
		return $?
	fi
	
	gtk.init ${!__GTK_WIDGET_OBJ_INIT[@]}	# Atualizar
	eval yad ${__GTK_WIDGET_OBJ_INIT[$1]}	# Executar

	return $?
}

source.__INIT__
# /* __GTK_SH */
