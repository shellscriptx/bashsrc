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
readonly -A __GTK_WIDGET=(
[gtk_button]=BTN
[gtk_passwordbox]=H
[gtk_spin_button]=NUM
[gtk_editbox]=
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

# estruturas
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
var gtk_notebook_t		struct_t

# widget
gtk_widget_t.__add__	type		flag 	\
			label		str	\
			icon		str	\
			tooltip		str	\
			id		uint 	\
			value		str	\
			exec		str	\
			callback	uint	

# botão
gtk_widget_button_t.__add__	label		str	\
				tooltip		str	\
				icon		str	\
				id		uint
# column
gtk_widget_column_t.__add__	type	flag	\
				label	str

gtk_widget_bar_t.__add__	type	flag	\
				label	str

# geral
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
			output			file

# calendário
gtk_calendar_t.__add__	window		gtk_window_t	\
			day		uint 		\
			month		uint 		\
			year		uint 		\
			details		file 		\
			show_weeks	bool

# paleta de cores
gtk_color_t.__add__	window		gtk_window_t	\
			init_color	flag		\
			gtk_palette	bool		\
			palette		file		\
			expand_palette	bool		\
			mode		flag		\
			extra		bool		\
			alpha		bool

# caixa drag-n-grop
gtk_dnd_t.__add__	window		gtk_window_t

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
			ricon_action	str

# caixa de seleção de arquivos
gtk_file_t.__add__	window			gtk_window_t	\
			directory		bool		\
			save			bool		\
			confirm_overwrite	str

# caixa de seleção de fontes
gtk_font_t.__add__	window		gtk_window_t 	\
			preview		str 		\
			separate_output	bool

# formulário
gtk_form_t.__add__	window		gtk_window_t	\
			widget		gtk_widget_t[]	\
			align		flag		\
			columns		uint		\
			scroll		bool		\
			output_by_row	bool		\
			focus_field	uint		\
			cycle_read	bool

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

# Guias
gtk_notebook_t.__add__		key		uint	\
				tab		str	\
				tab_pos		flag	\
				tab_borders	uint

function gtk.show()
{
	getopt.parse 1 "gtk_object:var:+:$1" ${@:2}

	local 	objtype=$(__typeof__ $1)
	local	object				

	case $objtype in
		gtk_calendar_t)
			object='calendar'

			local 	day=$($1.day)			\
				month=$($1.month)		\
				year=$($1.year)			\
				details=$($1.details)		\
				show_weeks=$($1.show_weeks)
				show_weeks=${show_weeks#false}
			;;
		gtk_color_t)
			object='color'

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
			object='entry'

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
			object='file'

			local	directory=$($1.directory)	\
				save=$($1.save)			\
				confirm_overwrite=$($1.confirm_overwrite)
				directory=${directory#false}
				save=${save#false}
			;;
		gtk_font_t)
			object='font'
					
			local	preview=$($1.preview) \
				separate_output=$($1.separate_output)
				separate_output=${separate_output#false}
			;;
		gtk_form_t)
			object='form'

			local	obj=$($1.widget)			\
				align=$($1.align)			\
				columns=$($1.columns)			\
				scroll=$($1.scroll)			\
				output_by_row=$($1.output_by_row) 	\
				focus_field=$($1.focus_field)		\
				cycle_read=$($1.cycle_read)
				scroll=${scroll#false}
				output_by_row=${output_by_row#false}
				cycle_read=${cycle_read#false}
			
			if [[ $obj ]]; then
				local 	widgets=${!__GTK_WIDGET[@]}
				local 	widget callback fields i
				for ((i=0; i < $($obj.__sizeof__); i++)); do
					widget=$($obj[$i].type)
					callback=$($obj[$i].callback)
					if [[ $widget != @(${widgets[@]// /|}) ]]; then
						error.trace def 'widget' 'gtk_widget_t' "$widget" "$obj[$i]: objeto widget inválido"
						return $?
					elif [[ $widget == @(gtk_button|gtk_toogle_button) ]]; then
						fields[$i]="--field '$($obj[$i].label)"'!'"$($obj[$i].icon)"'!'"$($obj[$i].tooltip):${__GTK_WIDGET[$widget]}' \"${callback:+@echo ${callback}:\$(}bash -c '$($obj[$i].exec)'${callback:+)}\""
					else
						fields[$i]="--field '$($obj[$i].label):${__GTK_WIDGET[$widget]}' '$($obj[$i].value)'"
					fi
				done
			fi
			;;
		gtk_icons_t)
			object='icons'
			
			local	read_dir=$($1.read_dir)		\
				compact=$($1.compact)		\
				generic=$($1.generic)		\
				item_width=$($1.item_width)	\
				term=$($1.term)			\
				sort_by_name=$($1.sort_by_name)	\
				descend=$($1.descend)		\
				single_click=$($1.single_click)	\
				monitor=$($1.monitor)
				compact=${compact#false}
				generic=${generic#false}
				sort_by_name=${sort_by_name#false}
				descend=${descend#false}
				single_click=${single_click#false}
				monitor=${monitor#false}
			;;
		gtk_list_t)
			object='list'
			
			local	column=$($1.columns)			\
				checklist=$($1.checklist)		\
				radiolist=$($1.radiolist)		\
				no_headers=$($1.no_headers)		\
				no_click=$($1.no_click)			\
				no_rules_hint=($1.no_rules_hint)	\
				grid_lines=$($1.grid_lines)		\
				print_all=$($1.print_all)		\
				editable_cols=$($1.editable_cols)	\
				wrap_width=$($1.wrap_width)		\
				wrap_cols=$($1.wrap_cols)		\
				ellipsize=$($1.ellipsize)		\
				ellipsize_cols=$($1.ellipsize_cols)	\
				print_column=$($1.print_column)		\
				hide_column=$($1.hide_column)		\
				expand_column=$($1.expand_column)	\
				search_column=$($1.search_column)	\
				tooltip_column=$($1.tooltip_column)	\
				sep_column=$($1.sep_column)		\
				sep_value=$($1.sep_value)		\
				limit=$($1.limit)			\
				dclick_action=$($1.dclick_action)	\
				select_action=$($1.select_action)	\
				add_action=$($1.add_action)		\
				regex_search=$($1.regex_search)		\
				no_selection=$($1.no_selection)		\
				lstvalue=$($1.value)
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
							error.trace def 'column' 'gtk_widget_column_t' "$col_type" "$column[$i]: tipo da coluna inválida"
							return $?
						fi
					done
				fi
			;;
		gtk_multi_progress_t)
				object='multi-progress'
				
				local	bar=$($1.bar)			\
					watch_bar=$($1.watch_bar)	\
					align=$($1.align)		\
					auto_close=$($1.auto_close)	\
					auto_kill=$($1.auto_kill)
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
		gtk_notebook_t)
				object='notebook'
				
				local	key=$($1.key)			\
					tab=$($1.tab)			\
					tab_pos=$($1.tab_pos)		\
					tab_borders=$($1.tab_borders)
			;;
		gtk_dnd_t)	object='dnd';;
		*)	error.trace def 'gtk_object' 'var' "$objtype" 'tipo do objeto inválido'; return $?;;
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

	if [[ $button ]]; then
		local 	buttons
		for ((i=0; i < $($button.__sizeof__); i++)); do
			buttons[$i]="--button '$($button[$i].label)"'!'"$($button[$i].icon)"'!'"$($button[$i].tooltip):$($button[$i].id)'"
		done
	fi

	# inicializa objeto
	obj_parse="	${object:+--$object}
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
			${output:+&> '$output'}
			${plug:+&}"

		echo $obj_parse
		eval yad $obj_parse

		return $?
}

export -f gtk.show

source.__INIT__
# /* __GTK_SH */
