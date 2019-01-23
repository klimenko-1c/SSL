﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КонтекстВыбора;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	УстановитьУсловноеОформление();
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если Не Объект.Ссылка.Пустая() Тогда
		Возврат;
	КонецЕсли;	
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан("Справочник.Календари", ЭтотОбъект);
	
	// Если производственный календарь в системе единственный, заполняем его по умолчанию.
	ПроизводственныеКалендари = Справочники.ПроизводственныеКалендари.СписокПроизводственныхКалендарей();
	Если ПроизводственныеКалендари.Количество() = 1 Тогда
		Объект.ПроизводственныйКалендарь = ПроизводственныеКалендари[0];
	КонецЕсли;
	
	Объект.СпособЗаполнения = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоНеделям;
	
	ДлинаЦикла = 7;
	
	Объект.ДатаНачала = НачалоГода(ТекущаяДатаСеанса());
	Объект.ДатаОтсчета = НачалоГода(ТекущаяДатаСеанса());
	
	УстановитьЭлементыНастройкиЗаполнения(ЭтотОбъект);
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	
	ЗаполнитьПредставлениеРасписания(ЭтотОбъект);
	
	УстановитьДоступностьУчитыватьПраздники(ЭтотОбъект);
	
	УточнитьДатуЗаполненности();
	
	ЗаполнитьДаннымиТекущегоГода(Параметры.ЗначениеКопирования);
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Истина);
	
	УстановитьДоступностьРасписанияПредпраздничногоДня(ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ДлинаЦикла = Объект.ШаблонЗаполнения.Количество();
	
	УстановитьЭлементыНастройкиЗаполнения(ЭтотОбъект);
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	
	ЗаполнитьПредставлениеРасписания(ЭтотОбъект);
	
	УстановитьДоступностьУчитыватьПраздники(ЭтотОбъект);
	
	УточнитьДатуЗаполненности();
	
	ЗаполнитьДаннымиТекущегоГода();
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Истина);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Ложь);
	
	УстановитьДоступностьРасписанияПредпраздничногоДня(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("Справочник.Календари.Форма.РасписаниеРаботы") Тогда
		
		Если ВыбранноеЗначение = Неопределено Или ТолькоПросмотр Тогда
			Возврат;
		КонецЕсли;
		
		// Удаляем ранее заполненное расписания для этого дня.
		СтрокиДня = Новый Массив;
		Для Каждого СтрокаРасписания Из Объект.РасписаниеРаботы Цикл
			Если СтрокаРасписания.НомерДня = КонтекстВыбора.НомерДня Тогда
				СтрокиДня.Добавить(СтрокаРасписания.ПолучитьИдентификатор());
			КонецЕсли;
		КонецЦикла;
		Для Каждого ИдентификаторСтроки Из СтрокиДня Цикл
			Объект.РасписаниеРаботы.Удалить(Объект.РасписаниеРаботы.НайтиПоИдентификатору(ИдентификаторСтроки));
		КонецЦикла;
		
		// Заполняем расписание работы на день.
		Для Каждого ОписаниеИнтервала Из ВыбранноеЗначение.РасписаниеРаботы Цикл
			НоваяСтрока = Объект.РасписаниеРаботы.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ОписаниеИнтервала);
			НоваяСтрока.НомерДня = КонтекстВыбора.НомерДня;
		КонецЦикла;
		
		Если КонтекстВыбора.НомерДня = 0 Тогда
			РасписаниеПредпраздничногоДня = ПредставлениеРасписанияДня(ЭтотОбъект, 0);
		КонецЕсли;
		
		УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
		УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
		
		Если КонтекстВыбора.Источник = "ШаблонЗаполненияВыбор" Тогда
			
			СтрокаШаблона = Объект.ШаблонЗаполнения.НайтиПоИдентификатору(КонтекстВыбора.ИдентификаторСтрокиШаблона);
			СтрокаШаблона.ДеньВключенВГрафик = ВыбранноеЗначение.РасписаниеРаботы.Количество() > 0; // расписание заполнено
			СтрокаШаблона.ПредставлениеРасписания = ПредставлениеРасписанияДня(ЭтотОбъект, КонтекстВыбора.НомерДня);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Перем НомерГода;
	
	Если Не ПараметрыЗаписи.Свойство("НомерГода", НомерГода) Тогда
		НомерГода = НомерТекущегоГода;
	КонецЕсли;
	
	// Если данные текущего года отредактированы вручную, 
	// то записываем их как есть, остальные периоды обновляем по шаблону.
	
	Если МодифицированностьРезультата Тогда
		Справочники.Календари.ЗаписатьДанныеГрафикаВРегистр(ТекущийОбъект.Ссылка, ДниГрафика, Дата(НомерГода, 1, 1), Дата(НомерГода, 12, 31), Истина);
	КонецЕсли;
	ЗаписатьПризнакРучногоРедактирования(ТекущийОбъект, НомерГода);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ДлинаЦикла = Объект.ШаблонЗаполнения.Количество();
	
	УстановитьЭлементыНастройкиЗаполнения(ЭтотОбъект);
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	
	ЗаполнитьПредставлениеРасписания(ЭтотОбъект);
	
	УточнитьДатуЗаполненности();
	
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Ложь);
	
	ЗаполнитьДаннымиТекущегоГода();
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если Объект.СпособЗаполнения = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоЦикламПроизвольнойДлины Тогда
		ПроверяемыеРеквизиты.Добавить("ДлинаЦикла");
		ПроверяемыеРеквизиты.Добавить("ДатаОтсчета");
	КонецЕсли;
	
	Если Объект.ШаблонЗаполнения.НайтиСтроки(Новый Структура("ДеньВключенВГрафик", Истина)).Количество() = 0 Тогда
		ОбщегоНазначения.СообщитьПользователю(
			НСтр("ru = 'Не отмечены дни, включаемые в график работы'"), , "Объект.ШаблонЗаполнения", , Отказ);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаполнитьПоШаблону(Команда)
	
	ЗаполнитьПоШаблонуНаСервере();
	
	Элементы.ГрафикРаботы.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура РезультатЗаполнения(Команда)
	
	Элементы.Страницы.ТекущаяСтраница = Элементы.РезультатЗаполненияСтраница;
	
	Если Не РезультатЗаполненПоШаблону Тогда
		ЗаполнитьПоШаблонуНаСервере(Истина);
	КонецЕсли;
	
	Элементы.ГрафикРаботы.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаЗаполнения(Команда)
	
	Элементы.Страницы.ТекущаяСтраница = Элементы.НастройкаЗаполненияСтраница;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура ПроизводственныйКалендарьПриИзменении(Элемент)
	
	УстановитьДоступностьУчитыватьПраздники(ЭтотОбъект);
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура СпособЗаполненияПриИзменении(Элемент)

	УстановитьЭлементыНастройкиЗаполнения(ЭтотОбъект);
	
	УточнитьДатуОтсчета();	
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	ЗаполнитьПредставлениеРасписания(ЭтотОбъект);

	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаНачалаПриИзменении(Элемент)
	
	Если Объект.ДатаНачала < Дата(1900, 1, 1) Тогда
		Объект.ДатаНачала = НачалоГода(ОбщегоНазначенияКлиент.ДатаСеанса());
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаОтсчетаПриИзменении(Элемент)
	
	УточнитьДатуОтсчета();
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ДлинаЦиклаПриИзменении(Элемент)
	
	СформироватьШаблонЗаполнения(Объект.СпособЗаполнения, Объект.ШаблонЗаполнения, ДлинаЦикла, Объект.ДатаОтсчета);
	ЗаполнитьПредставлениеРасписания(ЭтотОбъект);

	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура УчитыватьПраздникиПриИзменении(Элемент)
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
	УстановитьДоступностьРасписанияПредпраздничногоДня(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьРасписанияПредпраздничногоДня(Форма)
	Форма.Элементы.РасписаниеПредпраздничногоДня.Доступность = Форма.Объект.УчитыватьПраздники;
КонецПроцедуры

&НаКлиенте
Процедура ШаблонЗаполненияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтрокаШаблона = Объект.ШаблонЗаполнения.НайтиПоИдентификатору(ВыбраннаяСтрока);
	
	КонтекстВыбора = Новый Структура;
	КонтекстВыбора.Вставить("Источник", "ШаблонЗаполненияВыбор");
	КонтекстВыбора.Вставить("НомерДня", СтрокаШаблона.НомерСтроки);
	КонтекстВыбора.Вставить("ПредставлениеРасписания", СтрокаШаблона.ПредставлениеРасписания);
	КонтекстВыбора.Вставить("ИдентификаторСтрокиШаблона", ВыбраннаяСтрока);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РасписаниеРаботы", РасписаниеРаботы(КонтекстВыбора.НомерДня));
	ПараметрыФормы.Вставить("ТолькоПросмотр", ТолькоПросмотр);
	
	ОткрытьФорму("Справочник.Календари.Форма.РасписаниеРаботы", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ШаблонЗаполненияДеньВключенВГрафикПриИзменении(Элемент)
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Ложь);
	УстановитьСнятьМодифицированностьШаблона(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура РасписаниеПредпраздничногоДняНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	КонтекстВыбора = Новый Структура;
	КонтекстВыбора.Вставить("Источник", "РасписаниеПредпраздничногоДняНажатие");
	КонтекстВыбора.Вставить("НомерДня", 0);
	КонтекстВыбора.Вставить("ПредставлениеРасписания", РасписаниеПредпраздничногоДня);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РасписаниеРаботы", РасписаниеРаботы(КонтекстВыбора.НомерДня));
	ПараметрыФормы.Вставить("ТолькоПросмотр", ТолькоПросмотр);
	
	ОткрытьФорму("Справочник.Календари.Форма.РасписаниеРаботы", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ГоризонтПланированияПриИзменении(Элемент)
	
	УточнитьЗаполненностьГрафика(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияКомментария(Элемент.ТекстРедактирования, ЭтотОбъект, "Объект.Описание");
	
КонецПроцедуры

&НаКлиенте
Процедура НомерТекущегоГодаПриИзменении(Элемент)
	
	Если НомерТекущегоГода < Год(Объект.ДатаНачала)
		Или (ЗначениеЗаполнено(Объект.ДатаОкончания) И НомерТекущегоГода > Год(Объект.ДатаОкончания)) Тогда
		НомерТекущегоГода = НомерПредыдущегоГода;
		Возврат;
	КонецЕсли;
	
	ЗаписыватьДанныеГрафика = Ложь;
	
	Если МодифицированностьРезультата Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Записать измененные данные за %1 год?'"), Формат(НомерПредыдущегоГода, "ЧГ=0"));
		
		Оповещение = Новый ОписаниеОповещения("НомерТекущегоГодаПриИзмененииЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстСообщения, РежимДиалогаВопрос.ДаНет);
		Возврат;
		
	КонецЕсли;
	
	ОбработатьИзменениеГода(ЗаписыватьДанныеГрафика);
	
	УстановитьСнятьМодифицированностьРезультата(ЭтотОбъект, Ложь);
	
	Элементы.ГрафикРаботы.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура ГрафикРаботыПриВыводеПериода(Элемент, ОформлениеПериода)
	
	Для Каждого СтрокаОформленияПериода Из ОформлениеПериода.Даты Цикл
		Если ДниГрафика.Получить(СтрокаОформленияПериода.Дата) = Неопределено Тогда
			ЦветТекстаДня = ОбщегоНазначенияКлиент.ЦветСтиля("ВидДняПроизводственногоКалендаряНеУказанЦвет");
		Иначе
			ЦветТекстаДня = ОбщегоНазначенияКлиент.ЦветСтиля("ВидДняПроизводственногоКалендаряРабочийЦвет");
		КонецЕсли;
		СтрокаОформленияПериода.ЦветТекста = ЦветТекстаДня;
		// Ручное редактирование
		Если ДниИзмененные.Получить(СтрокаОформленияПериода.Дата) = Неопределено Тогда
			ЦветФонаДня = ОбщегоНазначенияКлиент.ЦветСтиля("ЦветФонаПоля");
		Иначе
			ЦветФонаДня = ОбщегоНазначенияКлиент.ЦветСтиля("ДатаГрафикаИзмененнаяФон");
		КонецЕсли;
		СтрокаОформленияПериода.ЦветФона = ЦветФонаДня;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ГрафикРаботыВыбор(Элемент, ВыбраннаяДата)
	
	Если ДниГрафика.Получить(ВыбраннаяДата) = Неопределено Тогда
		// Включаем в график
		ГрафикиРаботыКлиент.ВставитьВФиксированноеСоответствие(ДниГрафика, ВыбраннаяДата, Истина);
		ДеньВключенВГрафик = Истина;
	Иначе
		// Исключаем из графика
		ГрафикиРаботыКлиент.УдалитьИзФиксированногоСоответствия(ДниГрафика, ВыбраннаяДата);
		ДеньВключенВГрафик = Ложь;
	КонецЕсли;
	
	// Фиксируем ручное изменение на дату.
	ГрафикиРаботыКлиент.ВставитьВФиксированноеСоответствие(ДниИзмененные, ВыбраннаяДата, ДеньВключенВГрафик);
	
	Элементы.ГрафикРаботы.Обновить();
	
	УстановитьСнятьПризнакРучногоРедактирования(ЭтотОбъект, Истина);
	УстановитьСнятьМодифицированностьРезультата(ЭтотОбъект, Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ШаблонЗаполненияПредставлениеРасписания.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ШаблонЗаполнения.ПредставлениеРасписания");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ШаблонЗаполнения.ДеньВключенВГрафик");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("Текст", ПредставлениеПустогоРасписания());

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ШаблонЗаполненияНомерСтроки.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.СпособЗаполнения");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Перечисления.СпособыЗаполненияГрафикаРаботы.ПоНеделям;

	Элемент.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ЗаполненностьИнформационныйТекст.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТребуетЗаполнения");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ПросроченныеДанныеЦвет);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РезультатЗаполненияИнформационныйТекст.Имя);

	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РезультатЗаполненПоШаблону");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РучноеРедактирование");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ПросроченныеДанныеЦвет);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РасписаниеПредпраздничногоДня.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РасписаниеПредпраздничногоДня");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.УчитыватьПраздники");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("Текст", ПредставлениеПустогоРасписания());

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьЭлементыНастройкиЗаполнения(Форма)
	
	ДоступностьНастройки = Форма.Объект.СпособЗаполнения = ПредопределенноеЗначение("Перечисление.СпособыЗаполненияГрафикаРаботы.ПоЦикламПроизвольнойДлины");
	
	Форма.Элементы.ДлинаЦикла.ТолькоПросмотр = Не ДоступностьНастройки;
	Форма.Элементы.ДатаОтсчета.ТолькоПросмотр = Не ДоступностьНастройки;
	
	Форма.Элементы.ДатаОтсчета.АвтоОтметкаНезаполненного = ДоступностьНастройки;
	Форма.Элементы.ДатаОтсчета.ОтметкаНезаполненного = ДоступностьНастройки И Не ЗначениеЗаполнено(Форма.Объект.ДатаОтсчета);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура СформироватьШаблонЗаполнения(СпособЗаполнения, ШаблонЗаполнения, Знач ДлинаЦикла, Знач ДатаОтсчета = Неопределено)
	
	// Формирует таблицу редактирования шаблона заполнения по дням.
	
	Если СпособЗаполнения = ПредопределенноеЗначение("Перечисление.СпособыЗаполненияГрафикаРаботы.ПоНеделям") Тогда
		ДлинаЦикла = 7;
	КонецЕсли;
	
	Пока ШаблонЗаполнения.Количество() > ДлинаЦикла Цикл
		ШаблонЗаполнения.Удалить(ШаблонЗаполнения.Количество() - 1);
	КонецЦикла;

	Пока ШаблонЗаполнения.Количество() < ДлинаЦикла Цикл
		ШаблонЗаполнения.Добавить();
	КонецЦикла;
	
	Если СпособЗаполнения = ПредопределенноеЗначение("Перечисление.СпособыЗаполненияГрафикаРаботы.ПоНеделям") Тогда
		ШаблонЗаполнения[0].ПредставлениеДня = НСтр("ru = 'Понедельник'");
		ШаблонЗаполнения[1].ПредставлениеДня = НСтр("ru = 'Вторник'");
		ШаблонЗаполнения[2].ПредставлениеДня = НСтр("ru = 'Среда'");
		ШаблонЗаполнения[3].ПредставлениеДня = НСтр("ru = 'Четверг'");
		ШаблонЗаполнения[4].ПредставлениеДня = НСтр("ru = 'Пятница'");
		ШаблонЗаполнения[5].ПредставлениеДня = НСтр("ru = 'Суббота'");
		ШаблонЗаполнения[6].ПредставлениеДня = НСтр("ru = 'Воскресенье'");
	Иначе
		ДатаДня = ДатаОтсчета;
		Для Каждого СтрокаДня Из ШаблонЗаполнения Цикл
			СтрокаДня.ПредставлениеДня = Формат(ДатаДня, "ДФ=д.ММ");
			СтрокаДня.ПредставлениеРасписания = ПредставлениеПустогоРасписания();
			ДатаДня = ДатаДня + 86400;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьПредставлениеРасписания(Форма)
	
	Для Каждого СтрокаШаблона Из Форма.Объект.ШаблонЗаполнения Цикл
		СтрокаШаблона.ПредставлениеРасписания = ПредставлениеРасписанияДня(Форма, СтрокаШаблона.НомерСтроки);
	КонецЦикла;
	
	Форма.РасписаниеПредпраздничногоДня = ПредставлениеРасписанияДня(Форма, 0);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПредставлениеРасписанияДня(Форма, НомерДня)
	
	ПредставлениеИнтервалов = "";
	Секунд = 0;
	Для Каждого СтрокаРасписания Из Форма.Объект.РасписаниеРаботы Цикл
		Если СтрокаРасписания.НомерДня <> НомерДня Тогда
			Продолжить;
		КонецЕсли;
		ПредставлениеИнтервала = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1-%2, ", Формат(СтрокаРасписания.ВремяНачала, "ДФ=ЧЧ:мм; ДП="), Формат(СтрокаРасписания.ВремяОкончания, "ДФ=ЧЧ:мм; ДП="));
		ПредставлениеИнтервалов = ПредставлениеИнтервалов + ПредставлениеИнтервала;
		Если Не ЗначениеЗаполнено(СтрокаРасписания.ВремяОкончания) Тогда
			СекундИнтервала = КонецДня(СтрокаРасписания.ВремяОкончания) - СтрокаРасписания.ВремяНачала + 1;
		Иначе
			СекундИнтервала = СтрокаРасписания.ВремяОкончания - СтрокаРасписания.ВремяНачала;
		КонецЕсли;
		Секунд = Секунд + СекундИнтервала;
	КонецЦикла;
	СтроковыеФункцииКлиентСервер.УдалитьПоследнийСимволВСтроке(ПредставлениеИнтервалов, 2);
	
	Если Секунд = 0 Тогда
		Возврат ПредставлениеПустогоРасписания();
	КонецЕсли;
	
	Часов = Окр(Секунд / 3600, 1);
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 ч. (%2)'"), Часов, ПредставлениеИнтервалов);
	
КонецФункции

&НаКлиенте
Функция РасписаниеРаботы(НомерДня)
	
	РасписаниеДня = Новый Массив;
	
	Для Каждого СтрокаРасписания Из Объект.РасписаниеРаботы Цикл
		Если СтрокаРасписания.НомерДня = НомерДня Тогда
			РасписаниеДня.Добавить(Новый Структура("ВремяНачала, ВремяОкончания", СтрокаРасписания.ВремяНачала, СтрокаРасписания.ВремяОкончания));
		КонецЕсли;
	КонецЦикла;
	
	Возврат РасписаниеДня;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПредставлениеПустогоРасписания()
	
	Возврат НСтр("ru = 'Заполнить расписание'");
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьУчитыватьПраздники(Форма)
	
	Форма.Элементы.УчитыватьПраздники.Доступность = ЗначениеЗаполнено(Форма.Объект.ПроизводственныйКалендарь);
	Если Не Форма.Элементы.УчитыватьПраздники.Доступность Тогда
		Форма.Объект.УчитыватьПраздники = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УточнитьДатуЗаполненности()
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	МАКСИМУМ(КалендарныеГрафики.ДатаГрафика) КАК Дата
	|ИЗ
	|	РегистрСведений.КалендарныеГрафики КАК КалендарныеГрафики
	|ГДЕ
	|	КалендарныеГрафики.Календарь = &ГрафикРаботы";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ГрафикРаботы", Объект.Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ДатаЗаполненности = Неопределено;
	Если Выборка.Следующий() Тогда
		ДатаЗаполненности = Выборка.Дата;
	КонецЕсли;	
	
	УточнитьЗаполненностьГрафика(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УточнитьЗаполненностьГрафика(Форма)
	
	Форма.ТребуетЗаполнения = Ложь;
	
	Если Форма.Параметры.Ключ.Пустая() Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Форма.ДатаЗаполненности) Тогда
		Форма.ЗаполненностьИнформационныйТекст = НСтр("ru = 'График работы не заполнен'");
		Форма.ТребуетЗаполнения = Истина;
	Иначе	
		Если Не ЗначениеЗаполнено(Форма.Объект.ГоризонтПланирования) Тогда
			ИнформационныйТекст = НСтр("ru = 'График работы заполнен до %1'");
			Форма.ЗаполненностьИнформационныйТекст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ИнформационныйТекст, Формат(Форма.ДатаЗаполненности, "ДЛФ=D"));
		Иначе											
			#Если ВебКлиент Или ТонкийКлиент ИЛИ МобильныйКлиент Тогда
				ТекущаяДата = ОбщегоНазначенияКлиент.ДатаСеанса();
			#Иначе
				ТекущаяДата = ТекущаяДатаСеанса();
			#КонецЕсли
			КонецГоризонтаПланирования = ДобавитьМесяц(ТекущаяДата, Форма.Объект.ГоризонтПланирования);
			ИнформационныйТекст = НСтр("ru = 'График работы заполнен до %1, с учетом горизонта планирования график должен быть заполнен до %2'");
			Форма.ЗаполненностьИнформационныйТекст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ИнформационныйТекст, Формат(Форма.ДатаЗаполненности, "ДЛФ=D"), Формат(КонецГоризонтаПланирования, "ДЛФ=D"));
			Если КонецГоризонтаПланирования > Форма.ДатаЗаполненности Тогда
				Форма.ТребуетЗаполнения = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Форма.Элементы.ЗаполненностьДекорация.Картинка = ?(Форма.ТребуетЗаполнения, БиблиотекаКартинок.Предупреждение, БиблиотекаКартинок.Информация);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПоШаблонуНаСервере(СохранятьРучноеРедактирование = Ложь)

	ДниВключенныеВГрафик = Справочники.Календари.ДниВключенныеВГрафик(
								Объект.ДатаНачала, 
								Объект.СпособЗаполнения, 
								Объект.ШаблонЗаполнения, 
								Объект.ДатаОкончания,
								Объект.ПроизводственныйКалендарь, 
								Объект.УчитыватьПраздники, 
								Объект.ДатаОтсчета);
	
	Если РучноеРедактирование Тогда
		Если СохранятьРучноеРедактирование Тогда
			// Переносим ручные корректировки.
			Для Каждого КлючИЗначение Из ДниИзмененные Цикл
				ДатаИзменений = КлючИЗначение.Ключ;
				ДеньВключенВГрафик = КлючИЗначение.Значение;
				Если ДеньВключенВГрафик Тогда
					ДниВключенныеВГрафик.Вставить(ДатаИзменений, Истина);
				Иначе
					ДниВключенныеВГрафик.Удалить(ДатаИзменений);
				КонецЕсли;
			КонецЦикла;
		Иначе
			УстановитьСнятьМодифицированностьРезультата(ЭтотОбъект, Истина);
			УстановитьСнятьПризнакРучногоРедактирования(ЭтотОбъект, Ложь);
		КонецЕсли;
	КонецЕсли;
	
	// Переносим результат в исходное соответствие заполнения, 
	// чтобы не «затереть» даты, не входящие в интервал заполнения.
	ДниГрафикаСоответствие = Новый Соответствие(ДниГрафика);
	ДатаДня = Объект.ДатаНачала;
	ДатаОкончания = Объект.ДатаОкончания;
	Если Не ЗначениеЗаполнено(ДатаОкончания) Тогда
		ДатаОкончания = КонецГода(Объект.ДатаНачала);
	КонецЕсли;
	Пока ДатаДня <= ДатаОкончания Цикл
		ДеньВключенВГрафик = ДниВключенныеВГрафик[ДатаДня];
		Если ДеньВключенВГрафик = Неопределено Тогда
			ДниГрафикаСоответствие.Удалить(ДатаДня);
		Иначе
			ДниГрафикаСоответствие.Вставить(ДатаДня, ДеньВключенВГрафик);
		КонецЕсли;
		ДатаДня = ДатаДня + 86400;
	КонецЦикла;
	
	ДниГрафика = Новый ФиксированноеСоответствие(ДниГрафикаСоответствие);
	
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Истина);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДаннымиТекущегоГода(ЗначениеКопирования = Неопределено)
	
	// Заполняет форму данными текущего года.
	
	НастроитьПолеКалендаря();
	
	Если ЗначениеЗаполнено(ЗначениеКопирования) Тогда
		ГрафикСсылка = ЗначениеКопирования;
	Иначе
		ГрафикСсылка = Объект.Ссылка;
	КонецЕсли;
	
	ДниГрафика = Новый ФиксированноеСоответствие(
		Справочники.Календари.ПрочитатьДанныеГрафикаИзРегистра(ГрафикСсылка, НомерТекущегоГода));

	ПрочитатьПризнакРучногоРедактирования(Объект, НомерТекущегоГода);
	
	// Если нет ручных корректировок и данных тоже нет, то формируем результат по шаблону за выбранный год.
	Если ДниГрафика.Количество() = 0 И ДниИзмененные.Количество() = 0 Тогда
		ДниВключенныеВГрафик = Справочники.Календари.ДниВключенныеВГрафик(
									Объект.ДатаНачала, 
									Объект.СпособЗаполнения, 
									Объект.ШаблонЗаполнения, 
									Дата(НомерТекущегоГода, 12, 31),
									Объект.ПроизводственныйКалендарь, 
									Объект.УчитыватьПраздники, 
									Объект.ДатаОтсчета);
		ДниГрафика = Новый ФиксированноеСоответствие(ДниВключенныеВГрафик);
	КонецЕсли;
	
	УстановитьСнятьМодифицированностьРезультата(ЭтотОбъект, Ложь);
	УстановитьСнятьПризнакСоответствияРезультатовШаблону(ЭтотОбъект, Не МодифицированностьШаблона);

КонецПроцедуры

&НаСервере
Процедура ПрочитатьПризнакРучногоРедактирования(ТекущийОбъект, НомерГода)
	
	Если ТекущийОбъект.Ссылка.Пустая() Тогда
		УстановитьСнятьПризнакРучногоРедактирования(ЭтотОбъект, Ложь);
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	РучныеИзменения.ДатаГрафика
	|ИЗ
	|	РегистрСведений.РучныеИзмененияГрафиковРаботы КАК РучныеИзменения
	|ГДЕ
	|	РучныеИзменения.ГрафикРаботы = &ГрафикРаботы
	|	И РучныеИзменения.Год = &Год");
	
	Запрос.УстановитьПараметр("ГрафикРаботы", ТекущийОбъект.Ссылка);
	Запрос.УстановитьПараметр("Год", НомерГода);
	
	Соответствие = Новый Соответствие;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Соответствие.Вставить(Выборка.ДатаГрафика, Истина);
	КонецЦикла;
	ДниИзмененные = Новый ФиксированноеСоответствие(Соответствие);
	
	УстановитьСнятьПризнакРучногоРедактирования(ЭтотОбъект, ДниИзмененные.Количество() > 0);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьПризнакРучногоРедактирования(ТекущийОбъект, НомерГода)
	
	НаборЗаписей = РегистрыСведений.РучныеИзмененияГрафиковРаботы.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ГрафикРаботы.Установить(ТекущийОбъект.Ссылка);
	НаборЗаписей.Отбор.Год.Установить(НомерГода);
	
	Для Каждого КлючИЗначение Из ДниИзмененные Цикл
		СтрокаНабора = НаборЗаписей.Добавить();
		СтрокаНабора.ДатаГрафика = КлючИЗначение.Ключ;
		СтрокаНабора.ГрафикРаботы = ТекущийОбъект.Ссылка;
		СтрокаНабора.Год = НомерГода;
	КонецЦикла;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДанныеГрафикаРаботыНаГод(НомерГода)
	
	Справочники.Календари.ЗаписатьДанныеГрафикаВРегистр(Объект.Ссылка, ДниГрафика, Дата(НомерГода, 1, 1), Дата(НомерГода, 12, 31), Истина);
	ЗаписатьПризнакРучногоРедактирования(Объект, НомерГода);
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьИзменениеГода(ЗаписыватьДанныеГрафика)
	
	Если Не ЗаписыватьДанныеГрафика Тогда
		ЗаполнитьДаннымиТекущегоГода();
		Возврат;
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() Тогда
		Записать(Новый Структура("НомерГода", НомерПредыдущегоГода));
	Иначе
		ЗаписатьДанныеГрафикаРаботыНаГод(НомерПредыдущегоГода);
		ЗаполнитьДаннымиТекущегоГода();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСнятьПризнакРучногоРедактирования(Форма, РучноеРедактирование)
	
	Форма.РучноеРедактирование = РучноеРедактирование;
	
	Если Не РучноеРедактирование Тогда
		Форма.ДниИзмененные = Новый ФиксированноеСоответствие(Новый Соответствие);
	КонецЕсли;
	
	ЗаполнитьИнформационныйТекстРезультатаЗаполнения(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСнятьПризнакСоответствияРезультатовШаблону(Форма, РезультатЗаполненПоШаблону)
	
	Форма.РезультатЗаполненПоШаблону = РезультатЗаполненПоШаблону;
	
	ЗаполнитьИнформационныйТекстРезультатаЗаполнения(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСнятьМодифицированностьШаблона(Форма, МодифицированностьШаблона)
	
	Форма.МодифицированностьШаблона = МодифицированностьШаблона;
	
	Форма.Модифицированность = Форма.МодифицированностьШаблона Или Форма.МодифицированностьРезультата;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСнятьМодифицированностьРезультата(Форма, МодифицированностьРезультата)
	
	Форма.МодифицированностьРезультата = МодифицированностьРезультата;
	
	Форма.Модифицированность = Форма.МодифицированностьШаблона Или Форма.МодифицированностьРезультата;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьИнформационныйТекстРезультатаЗаполнения(Форма)
	
	ИнформационныйТекст = "";
	ИнформационнаяКартинка = Новый Картинка;
	ДоступноЗаполнениеПоШаблону = Ложь;
	Если Форма.РучноеРедактирование Тогда
		ИнформационныйТекст = НСтр("ru = 'График работы на текущий год изменен вручную. 
                                    |Нажмите «Заполнить по шаблону» чтобы вернуться к автоматическому заполнению.'");
		ИнформационнаяКартинка = БиблиотекаКартинок.Предупреждение;
		ДоступноЗаполнениеПоШаблону = Истина;
	Иначе
		Если Форма.РезультатЗаполненПоШаблону Тогда
			Если ЗначениеЗаполнено(Форма.Объект.ПроизводственныйКалендарь) Тогда
				ИнформационныйТекст = НСтр("ru = 'График работы автоматически обновляется при изменении производственного календаря за текущий год.'");
				ИнформационнаяКартинка = БиблиотекаКартинок.Информация;
			КонецЕсли;
		Иначе
			ИнформационныйТекст = НСтр("ru = 'Отображаемый результат не соответствует настройке шаблона. 
                                        |Нажмите «Заполнить по шаблону», чтобы увидеть как выглядит график работы с учетом изменений шаблона.'");
			ИнформационнаяКартинка = БиблиотекаКартинок.Предупреждение;
			ДоступноЗаполнениеПоШаблону = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Форма.РезультатЗаполненияИнформационныйТекст = ИнформационныйТекст;
	Форма.Элементы.РезультатЗаполненияДекорация.Картинка = ИнформационнаяКартинка;
	Форма.Элементы.ЗаполнитьПоШаблону.Доступность = ДоступноЗаполнениеПоШаблону;
	
	ЗаполнитьИнформационныйТекстРучногоРедактирования(Форма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьИнформационныйТекстРучногоРедактирования(Форма)
	
	ИнформационныйТекст = "";
	ИнформационнаяКартинка = Новый Картинка;
	Если Форма.РучноеРедактирование Тогда
		ИнформационнаяКартинка = БиблиотекаКартинок.Предупреждение;
		ИнформационныйТекст = НСтр("ru = 'График работы на текущий год изменен вручную. Изменения выделены в результатах заполнения.'");
	КонецЕсли;
	
	Форма.РучноеРедактированиеИнформационныйТекст = ИнформационныйТекст;
	Форма.Элементы.РучноеРедактированиеДекорация.Картинка = ИнформационнаяКартинка;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьПолеКалендаря()
	
	Если НомерТекущегоГода = 0 Тогда
		НомерТекущегоГода = Год(ТекущаяДатаСеанса());
	КонецЕсли;
	НомерПредыдущегоГода = НомерТекущегоГода;
	
	ГрафикРаботы = Дата(НомерТекущегоГода, 1, 1);
	Элементы.ГрафикРаботы.НачалоПериодаОтображения	= Дата(НомерТекущегоГода, 1, 1);
	Элементы.ГрафикРаботы.КонецПериодаОтображения	= Дата(НомерТекущегоГода, 12, 31);
		
КонецПроцедуры

&НаКлиенте
Процедура НомерТекущегоГодаПриИзмененииЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ЗаписыватьДанныеГрафика = Истина;
	КонецЕсли;
	
	ОбработатьИзменениеГода(ЗаписыватьДанныеГрафика);
	УстановитьСнятьМодифицированностьРезультата(ЭтотОбъект, Ложь);
	Элементы.ГрафикРаботы.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура УточнитьДатуОтсчета()
	
	Если Объект.ДатаОтсчета < Дата(1900, 1, 1) Тогда
		Объект.ДатаОтсчета = НачалоГода(ОбщегоНазначенияКлиент.ДатаСеанса());
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
