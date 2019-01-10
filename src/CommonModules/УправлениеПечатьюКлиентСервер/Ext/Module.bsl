﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

#Область УстаревшиеПроцедурыИФункции

// Устарела. Следует использовать ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды.
//
// Обновляет список команд печати в зависимости от текущего контекста.
//
// Параметры:
//  Форма - УправляемаяФорма - форма, для которой требуется обновление команд печати.
//  Источник - ДанныеФормыСтруктура, ТаблицаФормы - контекст для проверки условий (Форма.Объект или Форма.Элементы.Список).
//
Процедура ОбновитьКоманды(Форма, Источник) Экспорт
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(Форма, Источник);
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИменаПолейКоллекцииПечатныхФорм() Экспорт
	
	Поля = Новый Массив;
	Поля.Добавить("ИмяМакета");
	Поля.Добавить("ИмяВРЕГ");
	Поля.Добавить("СинонимМакета");
	Поля.Добавить("ТабличныйДокумент");
	Поля.Добавить("Экземпляров");
	Поля.Добавить("Картинка");
	Поля.Добавить("ПолныйПутьКМакету");
	Поля.Добавить("ИмяФайлаПечатнойФормы");
	Поля.Добавить("ОфисныеДокументы");
	
	Возврат Поля;
	
КонецФункции

#КонецОбласти
