﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
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
	
	Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.ПровайдерSMS");
	УстановитьПривилегированныйРежим(Истина);
	НастройкиПровайдера = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Владелец, "Пароль, Логин, ИмяОтправителя");
	УстановитьПривилегированныйРежим(Ложь);
	ЛогинДляОтправкиSMS = НастройкиПровайдера.Логин;
	ИмяОтправителя = НастройкиПровайдера.ИмяОтправителя;
	ПарольДляОтправкиSMS = ?(ЗначениеЗаполнено(НастройкиПровайдера.Пароль), ЭтотОбъект.УникальныйИдентификатор, "");
	
	ЗаполнитьОписаниеУслуги();
	
	Элементы.ЛогинДляОтправкиSMS.Заголовок = ОписаниеУслуги.ПредставлениеЛогина;
	Элементы.ПарольДляОтправкиSMS.Заголовок = ОписаниеУслуги.ПредставлениеПароля;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	ОбновитьПовторноИспользуемыеЗначения();
	Оповестить("Запись_НастройкиОтправкиSMS", ПараметрыЗаписи, ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	УстановитьПривилегированныйРежим(Истина);
	Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.ПровайдерSMS");
	Если ПарольДляОтправкиSMS <> Строка(ЭтотОбъект.УникальныйИдентификатор) Тогда
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ПарольДляОтправкиSMS);
	КонецЕсли;
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ЛогинДляОтправкиSMS, "Логин");
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ИмяОтправителя, "ИмяОтправителя");
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПровайдерSMSПриИзменении(Элемент)
	ЛогинДляОтправкиSMS = "";
	ПарольДляОтправкиSMS = "";
	ИмяОтправителя = "";
	ЗаполнитьОписаниеУслуги();
	Элементы.ЛогинДляОтправкиSMS.Заголовок = ОписаниеУслуги.ПредставлениеЛогина;
	Элементы.ПарольДляОтправкиSMS.Заголовок = ОписаниеУслуги.ПредставлениеПароля;
КонецПроцедуры

&НаКлиенте
Процедура ОписаниеУслугиНажатие(Элемент)
	АдресВИнтернете = ОписаниеУслуги.АдресВИнтернете;
	ОтправкаSMSКлиентПереопределяемый.ПриПолученииАдресаПровайдераВИнтернете(НаборКонстант.ПровайдерSMS, АдресВИнтернете);
	Если Не ПустаяСтрока(АдресВИнтернете) Тогда
		ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(АдресВИнтернете);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОписаниеУслуги()
	ОписаниеУслуги = Новый Структура;
	ОписаниеУслуги.Вставить("АдресВИнтернете", "");
	ОписаниеУслуги.Вставить("ПредставлениеЛогина", НСтр("ru = 'Логин'"));
	ОписаниеУслуги.Вставить("ПредставлениеПароля", НСтр("ru = 'Пароль'"));
	
	МодульОтправкаSMSЧерезПровайдера = ОтправкаSMS.МодульОтправкаSMSЧерезПровайдера(НаборКонстант.ПровайдерSMS);
	Если МодульОтправкаSMSЧерезПровайдера <> Неопределено Тогда
		МодульОтправкаSMSЧерезПровайдера.ЗаполнитьОписаниеУслуги(ОписаниеУслуги);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
