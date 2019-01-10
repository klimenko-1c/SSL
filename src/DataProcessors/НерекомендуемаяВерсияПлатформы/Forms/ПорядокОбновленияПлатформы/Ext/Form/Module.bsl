﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	БазаФайловая = ОбщегоНазначения.ИнформационнаяБазаФайловая();
	Если БазаФайловая Тогда
		МакетПорядокОбновления = Обработки.НерекомендуемаяВерсияПлатформы.ПолучитьМакет("ПорядокОбновленияДляФайловойБазы");
	Иначе
		МакетПорядокОбновления = Обработки.НерекомендуемаяВерсияПлатформы.ПолучитьМакет("ПорядокОбновленияДляКлиентСервернойБазы");
	КонецЕсли;
	
	ПорядокОбновленияПрограммы = МакетПорядокОбновления.ПолучитьТекст();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПорядокОбновленияПрограммыПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	Если ДанныеСобытия.Href <> Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(ДанныеСобытия.Href);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПечатьИнструкции(Команда)
	Элементы.ПорядокОбновленияПрограммы.Документ.execCommand("Print");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПорядокОбновленияПрограммыДокументСформирован(Элемент)
	// Видимость команды печати
	Если Не Элемент.Документ.queryCommandSupported("Print") Тогда
		Элементы.ПечатьИнструкции.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти