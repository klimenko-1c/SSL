﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив - список имен реквизитов объекта.
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	РедактируемыеРеквизиты = Новый Массив;
	РедактируемыеРеквизиты.Добавить("Комментарий");
	
	Возврат РедактируемыеРеквизиты;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
Процедура ДобавитьЗапросыНаИспользованиеВнешнихРесурсовВсехТомов(Запросы) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТомаХраненияФайлов.Ссылка КАК Ссылка,
	|	ТомаХраненияФайлов.ПолныйПутьLinux,
	|	ТомаХраненияФайлов.ПолныйПутьWindows,
	|	ТомаХраненияФайлов.ПометкаУдаления КАК ПометкаУдаления
	|ИЗ
	|	Справочник.ТомаХраненияФайлов КАК ТомаХраненияФайлов
	|ГДЕ
	|	ТомаХраненияФайлов.ПометкаУдаления = ЛОЖЬ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Запросы.Добавить(ЗапросНаИспользованиеВнешнихРесурсовДляТома(
			Выборка.Ссылка, Выборка.ПолныйПутьWindows, Выборка.ПолныйПутьLinux));
	КонецЦикла;
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ДобавитьЗапросыНаОтменуИспользованияВнешнихРесурсовВсехТомов(Запросы) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
		МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ТомаХраненияФайлов.Ссылка КАК Ссылка,
		|	ТомаХраненияФайлов.ПолныйПутьLinux,
		|	ТомаХраненияФайлов.ПолныйПутьWindows,
		|	ТомаХраненияФайлов.ПометкаУдаления КАК ПометкаУдаления
		|ИЗ
		|	Справочник.ТомаХраненияФайлов КАК ТомаХраненияФайлов";
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Пока Выборка.Следующий() Цикл
			Запросы.Добавить(МодульРаботаВБезопасномРежиме.ЗапросНаОчисткуРазрешенийИспользованияВнешнихРесурсов(
				Выборка.Ссылка));
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

// Только для внутреннего использования.
Функция ЗапросНаИспользованиеВнешнихРесурсовДляТома(Том, ПолныйПутьWindows, ПолныйПутьLinux) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
		МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
		Разрешения = Новый Массив;
		
		Если ЗначениеЗаполнено(ПолныйПутьWindows) Тогда
			Разрешения.Добавить(МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаФайловойСистемы(
				ПолныйПутьWindows, Истина, Истина));
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ПолныйПутьLinux) Тогда
			Разрешения.Добавить(МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаФайловойСистемы(
				ПолныйПутьLinux, Истина, Истина));
		КонецЕсли;
		
		Возврат МодульРаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(Разрешения, Том);
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#КонецЕсли
