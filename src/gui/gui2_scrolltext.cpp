#include "gui2_scrolltext.h"


GuiScrollText::GuiScrollText(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text), text_size(30), text_alignment(sp::Alignment::TopLeft)
{
    auto_scroll_down = false;
    scrollbar = new GuiScrollbar(this, id + "_SCROLL", 0, 1, 0, nullptr);
    scrollbar->setPosition(0, 0, sp::Alignment::TopRight)->setSize(50, GuiElement::GuiSizeMax);
}

GuiScrollText* GuiScrollText::setText(string text)
{
    this->text = text;
    return this;
}

string GuiScrollText::getText() const
{
    return text;
}

GuiScrollText* GuiScrollText::setScrollbarWidth(float width)
{
    scrollbar->setSize(width, GuiElement::GuiSizeMax);
    return this;
}

GuiScrollText* GuiScrollText::setTextAlignment(sp::Alignment alignment)
{
    text_alignment = alignment;
    return this;
}

void GuiScrollText::onDraw(sp::RenderTarget& renderer)
{
    auto scrollbar_size = scrollbar->getSize();
    auto text_rect = sp::Rect(rect.position.x, rect.position.y, rect.size.x - scrollbar_size.x, rect.size.y);

    auto compensated_text_alignment = text_alignment;
    switch (text_alignment) {
    case sp::Alignment::BottomLeft:
    case sp::Alignment::CenterLeft: compensated_text_alignment = sp::Alignment::TopLeft; break;
    case sp::Alignment::BottomCenter:
    case sp::Alignment::Center: compensated_text_alignment = sp::Alignment::TopCenter; break;
    case sp::Alignment::BottomRight:
    case sp::Alignment::CenterRight:  compensated_text_alignment = sp::Alignment::TopRight; break;
    }

    auto prepared = sp::RenderTarget::getDefaultFont()->prepare(this->text, 32, text_size, text_rect.size, compensated_text_alignment, sp::Font::FlagClip | sp::Font::FlagLineWrap);
    auto text_draw_size = prepared.getUsedAreaSize();

    int scroll_max = text_draw_size.y;
    if (scrollbar->getMax() != scroll_max)
    {
        int diff = scroll_max - scrollbar->getMax();
        scrollbar->setRange(0, scroll_max);
        scrollbar->setValueSize(text_rect.size.y);
        if (auto_scroll_down)
            scrollbar->setValue(scrollbar->getValue() + diff);
    }

    auto extra_height = text_rect.size.y - text_draw_size.y;
    auto needs_vertical_scroll = extra_height < 0;

    glm::vec2 offset {0, 0};
    auto flags = sp::Font::FlagLineWrap;

    if (needs_vertical_scroll)
    {
        // only necessary for scrolling text
        flags |= sp::Font::FlagClip;

        // when scrolled down, shift text up
        offset.y = -scrollbar->getValue();
    }
    else
    {
        // Text is fine without a scrollbar. Only now do center/bottom alignment actually make any sense.
        switch (text_alignment)
        {
        case sp::Alignment::CenterLeft:
        case sp::Alignment::Center:
        case sp::Alignment::CenterRight:
            offset.y = extra_height * 0.5f;
            break;
        case sp::Alignment::BottomLeft:
        case sp::Alignment::BottomCenter:
        case sp::Alignment::BottomRight:
            offset.y = extra_height;
            break;
        }

        // When the text is horizontally centered and we have no scrollbar, distribute the gained extra space.
        // We don't re-layout the text just for this, but still, it looks nicer.
        text_rect.size.x += scrollbar_size.x;
        switch (text_alignment)
        {
        case sp::Alignment::TopCenter:
        case sp::Alignment::Center:
        case sp::Alignment::BottomCenter:
            offset.x = scrollbar_size.x * 0.5;
            break;
        case sp::Alignment::TopRight:
        case sp::Alignment::CenterRight:
        case sp::Alignment::BottomRight:
            offset.x = scrollbar_size.x;
            break;
        }
    }

    if (offset.x != 0.0f || offset.y != 0.0f)
    {
        for (auto& g : prepared.data)
        {
            g.position += offset;
        }
    }

    scrollbar->setVisible(needs_vertical_scroll);
    renderer.drawText(text_rect, prepared, text_size, selectColor(colorConfig.textbox.forground), flags);
}
