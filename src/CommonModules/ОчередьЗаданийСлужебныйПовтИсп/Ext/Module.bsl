﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Возвращает соответствие имен методов их псевдонимам (в верхнем регистре)
// для вызова из очереди заданий.
//
// Возвращаемое значение:
//  ФиксированноеСоответствие
//   Ключ - Псевдоним метода
//   Значение - Имя метода для вызова.
//
Функция СоответствиеИменМетодовПсевдонимам() Экспорт
	
	Результат = Новый Соответствие;
	
	МетодыКонфигурации = Новый Соответствие;
	
	ИнтеграцияПодсистемБСП.ПриОпределенииПсевдонимовОбработчиков(МетодыКонфигурации);
	
	// Определяем методы служебных процедур для обработки ошибок заданий.
	МетодыКонфигурации.Вставить("ОчередьЗаданийСлужебный.ОбработатьОшибку");
	МетодыКонфигурации.Вставить("ОчередьЗаданийСлужебный.СнятьЗаданияОбработкиОшибок");
	
	ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков(МетодыКонфигурации);
	
	Для каждого КлючИЗначение Из МетодыКонфигурации Цикл
		Результат.Вставить(ВРег(КлючИЗначение.Ключ),
			?(ПустаяСтрока(КлючИЗначение.Значение), КлючИЗначение.Ключ, КлючИЗначение.Значение));
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает соответствие обработчиков ошибок псевдонимам методов, для которых они вызываются
// (в верхнем регистре).
//
// Возвращаемое значение:
//  ФиксированноеСоответствие
//   Ключ - Псевдоним метода
//   Значение - Полное имя метода обработчика.
//
Функция СоответствиеОбработчиковОшибокПсевдонимам() Экспорт
	
	ОбработчикиОшибок = Новый Соответствие;
	
	// Заполнение встроенных обработчиков ошибок.
	ОбработчикиОшибок.Вставить("ОчередьЗаданийСлужебный.ОбработатьОшибку","ОчередьЗаданийСлужебный.СнятьЗаданияОбработкиОшибок");
	ОбработчикиОшибок.Вставить("ОчередьЗаданийСлужебный.СнятьЗаданияОбработкиОшибок","ОчередьЗаданийСлужебный.СнятьЗаданияОбработкиОшибок");
	
	ИнтеграцияПодсистемБСП.ПриОпределенииОбработчиковОшибок(ОбработчикиОшибок);
	ОчередьЗаданийПереопределяемый.ПриОпределенииОбработчиковОшибок(ОбработчикиОшибок);
	
	Результат = Новый Соответствие;
	Для каждого КлючИЗначение Из ОбработчикиОшибок Цикл
		Результат.Вставить(ВРег(КлючИЗначение.Ключ), КлючИЗначение.Значение);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает описание параметров заданий очереди.
//
// Возвращаемое значение:
//  ТаблицаЗначений - описание параметров, колонки.
//   Имя - Строка - имя параметра.
//   ИмяВРег - Строка - имя параметра в верхнем регистре.
//   Поле - Строка - поле хранения параметра в таблице очереди.
//   Тип - ОписаниеТипов - допустимые типы значений параметров.
//   Отбор - Булево - параметр допустимо использовать для отбора.
//   Добавление - Булево - параметр допустимо указывать при добавлении
//    задания в очередь.
//   Изменение - Булево - параметр допустимо изменять.
//   Шаблон - Булево - параметр допустимо изменять для заданий
//    созданных по шаблону.
//   РазделениеДанных - Булево - параметр используется только при работе
//    разделенными заданиями.
//   ЗначениеДляНеразделенныхЗаданий - Строка - значение, которое необходимо
//     возвращать из API для разделенных параметров неразделенных заданий
//     (в виде строки, пригодной для подстановки в тексты запросов).
//
Функция ПараметрыЗаданийОчереди() Экспорт
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(0, ДопустимаяДлина.Переменная)));
	Результат.Колонки.Добавить("ИмяВРег", Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(0, ДопустимаяДлина.Переменная)));
	Результат.Колонки.Добавить("Поле", Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(0, ДопустимаяДлина.Переменная)));
	Результат.Колонки.Добавить("Тип", Новый ОписаниеТипов("ОписаниеТипов"));
	Результат.Колонки.Добавить("Отбор", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("Добавление", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("Изменение", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("Шаблон", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("РазделениеДанных", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("ЗначениеДляНеразделенныхЗаданий", Новый ОписаниеТипов("Строка"));
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "ОбластьДанных";
	ОписаниеПараметра.Поле = "ОбластьДанныхВспомогательныеДанные";
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Число");
	ОписаниеПараметра.Отбор = Истина;
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.РазделениеДанных = Истина;
	ОписаниеПараметра.ЗначениеДляНеразделенныхЗаданий = "-1";
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Идентификатор";
	ОписаниеПараметра.Поле = "Ссылка";
	МассивТипов = Новый Массив();
	СправочникиЗаданий = ОчередьЗаданийСлужебныйПовтИсп.ПолучитьСправочникиЗаданий();
	Для Каждого СправочникЗаданий Из СправочникиЗаданий Цикл
		МассивТипов.Добавить(ТипЗнч(СправочникЗаданий.ПустаяСсылка()));
	КонецЦикла;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов(МассивТипов);
	ОписаниеПараметра.Отбор = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Использование";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Булево");
	ОписаниеПараметра.Отбор = Истина;
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "ЗапланированныйМоментЗапуска";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Дата");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "СостояниеЗадания";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("ПеречислениеСсылка.СостоянияЗаданий");
	ОписаниеПараметра.Отбор = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "ЭксклюзивноеВыполнение";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Булево");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Шаблон";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("СправочникСсылка.ШаблоныЗаданийОчереди");
	ОписаниеПараметра.Отбор = Истина;
	ОписаниеПараметра.РазделениеДанных = Истина;
	ОписаниеПараметра.ЗначениеДляНеразделенныхЗаданий = "НЕОПРЕДЕЛЕНО";
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "ИмяМетода";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Строка");
	ОписаниеПараметра.Отбор = Истина;
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Параметры";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Массив");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Ключ";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Строка");
	ОписаниеПараметра.Отбор = Истина;
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "ИнтервалПовтораПриАварийномЗавершении";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Число");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "Расписание";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("РасписаниеРегламентногоЗадания, Неопределено");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	ОписаниеПараметра = Результат.Добавить();
	ОписаниеПараметра.Имя = "КоличествоПовторовПриАварийномЗавершении";
	ОписаниеПараметра.Поле = ОписаниеПараметра.Имя;
	ОписаниеПараметра.Тип = Новый ОписаниеТипов("Число");
	ОписаниеПараметра.Добавление = Истина;
	ОписаниеПараметра.Изменение = Истина;
	ОписаниеПараметра.Шаблон = Истина;
	
	Для каждого ОписаниеПараметра Из Результат Цикл
		ОписаниеПараметра.ИмяВРег = ВРег(ОписаниеПараметра.Имя);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает допустимые виды сравнения для отбора заданий очереди.
Функция ВидыСравненияОтбораЗаданий() Экспорт
	
	Результат = Новый Соответствие;
	Результат.Вставить(ВидСравнения.Равно, "=");
	Результат.Вставить(ВидСравнения.НеРавно, "<>");
	Результат.Вставить(ВидСравнения.ВСписке, "В");
	Результат.Вставить(ВидСравнения.НеВСписке, "НЕ В");
	
	Возврат Новый ФиксированноеСоответствие(Результат);
	
КонецФункции

// Возвращает часть текста запроса получения заданий для возврата 
// через программный интерфейс.
//
// Параметры:
//  СправочникЗаданий - СправочникМенеджер, менеджер справочника,
//  для которого получаются задания очереди. Используется для фильтрации полей
//  выборки, которые применимы не для всех справочников заданий.
//
Функция ПоляВыборкиОчередиЗаданий(Знач СправочникЗаданий = Неопределено) Экспорт
	
	ПоляВыборки = "";
	Для каждого ОписаниеПараметра Из ОчередьЗаданийСлужебныйПовтИсп.ПараметрыЗаданийОчереди() Цикл
		
		Если НЕ ПустаяСтрока(ПоляВыборки) Тогда
			ПоляВыборки = ПоляВыборки + "," + Символы.ПС;
		КонецЕсли;
		
		ОписаниеПоляВыборки = "Очередь." + ОписаниеПараметра.Поле + " КАК " + ОписаниеПараметра.Имя;
		
		Если СправочникЗаданий <> Неопределено Тогда
			
			Если ОписаниеПараметра.РазделениеДанных Тогда
				
				Если Не РаботаВМоделиСервисаПовтИсп.ЭтоРазделеннаяКонфигурация() ИЛИ Не РаботаВМоделиСервиса.ЭтоРазделенныйОбъектМетаданных(СправочникЗаданий, РаботаВМоделиСервиса.РазделительВспомогательныхДанных()) Тогда
					
					ОписаниеПоляВыборки = ОписаниеПараметра.ЗначениеДляНеразделенныхЗаданий + " КАК " + ОписаниеПараметра.Имя;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		ПоляВыборки = ПоляВыборки + Символы.Таб + ОписаниеПоляВыборки;
		
	КонецЦикла;
	
	Возврат ПоляВыборки;
	
КонецФункции

// Возвращает массив менеджеров справочников, которые могут использоваться для хранения заданий
// очереди заданий.
//
Функция ПолучитьСправочникиЗаданий() Экспорт
	
	МассивСправочников = Новый Массив();
	МассивСправочников.Добавить(Справочники.ОчередьЗаданий);
	
	Если РаботаВМоделиСервисаПовтИсп.ЭтоРазделеннаяКонфигурация() Тогда
		МодульОчередьЗаданийСлужебныйРазделениеДанных = ОбщегоНазначения.ОбщийМодуль("ОчередьЗаданийСлужебныйРазделениеДанных");
		МодульОчередьЗаданийСлужебныйРазделениеДанных.ПриЗаполненииСправочниковЗаданий(МассивСправочников);
	КонецЕсли;
	
	Возврат Новый ФиксированныйМассив(МассивСправочников);
	
КонецФункции

#КонецОбласти
