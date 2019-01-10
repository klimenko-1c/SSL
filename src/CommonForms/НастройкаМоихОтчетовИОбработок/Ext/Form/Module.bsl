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
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если Параметры.ВидОбработок = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительнаяОбработка Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Мои дополнительные обработки (%1)'"), 
			ДополнительныеОтчетыИОбработки.ПредставлениеРаздела(Параметры.СсылкаРаздела));
	ИначеЕсли Параметры.ВидОбработок = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительныйОтчет Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Мои дополнительные отчеты (%1)'"), 
			ДополнительныеОтчетыИОбработки.ПредставлениеРаздела(Параметры.СсылкаРаздела));
	КонецЕсли;
	
	ТипыКоманд = Новый Массив;
	ТипыКоманд.Добавить(Перечисления.СпособыВызоваДополнительныхОбработок.ВызовКлиентскогоМетода);
	ТипыКоманд.Добавить(Перечисления.СпособыВызоваДополнительныхОбработок.ВызовСерверногоМетода);
	ТипыКоманд.Добавить(Перечисления.СпособыВызоваДополнительныхОбработок.ОткрытиеФормы);
	ТипыКоманд.Добавить(Перечисления.СпособыВызоваДополнительныхОбработок.СценарийВБезопасномРежиме);
	
	Запрос = ДополнительныеОтчетыИОбработки.НовыйЗапросПоДоступнымКомандам(Параметры.ВидОбработок, Параметры.СсылкаРаздела, , ТипыКоманд, Ложь);
	ТаблицаРезультат = Запрос.Выполнить().Выгрузить();
	ИспользуемыеКоманды.Загрузить(ТаблицаРезультат);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СнятьФлажки(Команда)
	Для Каждого СтрокаТаблицы Из ИспользуемыеКоманды Цикл
		СтрокаТаблицы.Использование = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	Для Каждого СтрокаТаблицы Из ИспользуемыеКоманды Цикл
		СтрокаТаблицы.Использование = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	ЗаписатьНаборОбработокПользователя();
	ОповеститьОВыборе("ВыполненаНастройкаМоихОтчетовИОбработок");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаписатьНаборОбработокПользователя()
	Таблица = ИспользуемыеКоманды.Выгрузить();
	Таблица.Колонки.Ссылка.Имя        = "ДополнительныйОтчетИлиОбработка";
	Таблица.Колонки.Идентификатор.Имя = "ИдентификаторКоманды";
	Таблица.Колонки.Использование.Имя = "Доступно";
	ЗначенияИзмерений = Новый Структура("Пользователь", Пользователи.АвторизованныйПользователь());
	ЗначенияРесурсов  = Новый Структура;
	УстановитьПривилегированныйРежим(Истина);
	РегистрыСведений.ПользовательскиеНастройкиДоступаКОбработкам.ЗаписатьПакетНастроек(Таблица, ЗначенияИзмерений, ЗначенияРесурсов, Ложь);
КонецПроцедуры

#КонецОбласти
