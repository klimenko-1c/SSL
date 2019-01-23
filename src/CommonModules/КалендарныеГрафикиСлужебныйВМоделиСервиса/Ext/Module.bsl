﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Вызывается при изменении производственных календарей.
//
Процедура ЗапланироватьОбновлениеДанныхЗависимыхОтПроизводственныхКалендарей(Знач УсловияОбновления) Экспорт
	
	ПараметрыМетода = Новый Массив;
	ПараметрыМетода.Добавить(УсловияОбновления);
	ПараметрыМетода.Добавить(Новый УникальныйИдентификатор);

	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяМетода", "КалендарныеГрафикиСлужебныйВМоделиСервиса.ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей");
	ПараметрыЗадания.Вставить("Параметры", ПараметрыМетода);
	ПараметрыЗадания.Вставить("КоличествоПовторовПриАварийномЗавершении", 3);
	ПараметрыЗадания.Вставить("ОбластьДанных", -1);
	
	УстановитьПривилегированныйРежим(Истина);
	ОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков.
Процедура ПриОпределенииПсевдонимовОбработчиков(СоответствиеИменПсевдонимам) Экспорт
	
	СоответствиеИменПсевдонимам.Вставить("КалендарныеГрафикиСлужебныйВМоделиСервиса.ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура для вызова из очереди заданий, помещается туда в ЗапланироватьОбновлениеДанныхЗависимыхОтПроизводственныхКалендарей.
// 
// Параметры:
//  УсловияОбновления - ТаблицаЗначений с условиями обновления графиков.
//  ИдентификаторФайла - УникальныйИдентификатор файла обрабатываемых поставляемых данных.
//
Процедура ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей(Знач УсловияОбновления, Знач ИдентификаторФайла) Экспорт
	
	// Получение областей данных для обработки.
	ОбластиДляОбновления = ПоставляемыеДанные.ОбластиТребующиеОбработки(
		ИдентификаторФайла, "ДанныеПроизводственныхКалендарей");
		
	// Обновление графиков работы по областям данных.
	РаспространитьДанныеПроизводственныхКалендарейПоЗависимымДанным(УсловияОбновления, ОбластиДляОбновления, 
		ИдентификаторФайла, "ДанныеПроизводственныхКалендарей");

КонецПроцедуры

// Заполняет данные, зависимые от производственных календарей, по данным производственного календаря по всем ОД.
//
// Параметры:
//  УсловияОбновления - ТаблицаЗначений с условиями обновления графиков.
//  ОбластиДляОбновления - Массив со списком кодов областей.
//  ИдентификаторФайла - УникальныйИдентификатор файла обрабатываемых курсов.
//  КодОбработчика - Строка, код обработчика.
//
Процедура РаспространитьДанныеПроизводственныхКалендарейПоЗависимымДанным(Знач УсловияОбновления, 
	Знач ОбластиДляОбновления, Знач ИдентификаторФайла, Знач КодОбработчика)
	
	УсловияОбновления.Свернуть("КодПроизводственногоКалендаря, Год");
	
	Для каждого ОбластьДанных Из ОбластиДляОбновления Цикл
		УстановитьПривилегированныйРежим(Истина);
		РаботаВМоделиСервиса.УстановитьРазделениеСеанса(Истина, ОбластьДанных);
		УстановитьПривилегированныйРежим(Ложь);
		НачатьТранзакцию();
		Попытка
			КалендарныеГрафики.ЗаполнитьДанныеЗависимыеОтПроизводственныхКалендарей(УсловияОбновления);
			ПоставляемыеДанные.ОбластьОбработана(ИдентификаторФайла, КодОбработчика, ОбластьДанных);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Календарные графики.Распространение производственных календарей'", ОбщегоНазначения.КодОсновногоЯзыка()),
									УровеньЖурналаРегистрации.Ошибка,,,
									ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
