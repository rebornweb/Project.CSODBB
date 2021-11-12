namespace TransformXML
{
    partial class frmDoTransform
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmDoTransform));
            this.openXmlFile = new System.Windows.Forms.OpenFileDialog();
            this.openXslFile = new System.Windows.Forms.OpenFileDialog();
            this.saveTransformedFile = new System.Windows.Forms.SaveFileDialog();
            this.txtXmlIn = new System.Windows.Forms.TextBox();
            this.lblXmlIn = new System.Windows.Forms.Label();
            this.btnXmlIn = new System.Windows.Forms.Button();
            this.btnXslIn = new System.Windows.Forms.Button();
            this.lblXslIn = new System.Windows.Forms.Label();
            this.txtXslIn = new System.Windows.Forms.TextBox();
            this.btnTransformedOut = new System.Windows.Forms.Button();
            this.lblTransformedOut = new System.Windows.Forms.Label();
            this.txtTransformedOut = new System.Windows.Forms.TextBox();
            this.btnSave = new System.Windows.Forms.Button();
            this.btnClose = new System.Windows.Forms.Button();
            this.btnReset = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // txtXmlIn
            // 
            this.txtXmlIn.Location = new System.Drawing.Point(142, 12);
            this.txtXmlIn.Name = "txtXmlIn";
            this.txtXmlIn.Size = new System.Drawing.Size(298, 20);
            this.txtXmlIn.TabIndex = 0;
            // 
            // lblXmlIn
            // 
            this.lblXmlIn.AutoSize = true;
            this.lblXmlIn.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblXmlIn.Location = new System.Drawing.Point(29, 16);
            this.lblXmlIn.Name = "lblXmlIn";
            this.lblXmlIn.Size = new System.Drawing.Size(106, 13);
            this.lblXmlIn.TabIndex = 1;
            this.lblXmlIn.Text = "XML file to transform:";
            this.lblXmlIn.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // btnXmlIn
            // 
            this.btnXmlIn.Location = new System.Drawing.Point(447, 11);
            this.btnXmlIn.Name = "btnXmlIn";
            this.btnXmlIn.Size = new System.Drawing.Size(27, 23);
            this.btnXmlIn.TabIndex = 2;
            this.btnXmlIn.Text = "...";
            this.btnXmlIn.UseVisualStyleBackColor = true;
            this.btnXmlIn.Click += new System.EventHandler(this.btnXmlIn_Click);
            // 
            // btnXslIn
            // 
            this.btnXslIn.Location = new System.Drawing.Point(448, 48);
            this.btnXslIn.Name = "btnXslIn";
            this.btnXslIn.Size = new System.Drawing.Size(27, 23);
            this.btnXslIn.TabIndex = 5;
            this.btnXslIn.Text = "...";
            this.btnXslIn.UseVisualStyleBackColor = true;
            this.btnXslIn.Click += new System.EventHandler(this.btnXslIn_Click);
            // 
            // lblXslIn
            // 
            this.lblXslIn.AutoSize = true;
            this.lblXslIn.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblXslIn.Location = new System.Drawing.Point(18, 52);
            this.lblXslIn.Name = "lblXslIn";
            this.lblXslIn.Size = new System.Drawing.Size(116, 13);
            this.lblXslIn.TabIndex = 4;
            this.lblXslIn.Text = "XSL transform to apply:";
            this.lblXslIn.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // txtXslIn
            // 
            this.txtXslIn.Location = new System.Drawing.Point(142, 49);
            this.txtXslIn.Name = "txtXslIn";
            this.txtXslIn.Size = new System.Drawing.Size(299, 20);
            this.txtXslIn.TabIndex = 3;
            // 
            // btnTransformedOut
            // 
            this.btnTransformedOut.Location = new System.Drawing.Point(449, 85);
            this.btnTransformedOut.Name = "btnTransformedOut";
            this.btnTransformedOut.Size = new System.Drawing.Size(27, 23);
            this.btnTransformedOut.TabIndex = 8;
            this.btnTransformedOut.Text = "...";
            this.btnTransformedOut.UseVisualStyleBackColor = true;
            this.btnTransformedOut.Click += new System.EventHandler(this.btnTransformedOut_Click);
            // 
            // lblTransformedOut
            // 
            this.lblTransformedOut.AutoSize = true;
            this.lblTransformedOut.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.lblTransformedOut.Location = new System.Drawing.Point(20, 90);
            this.lblTransformedOut.Name = "lblTransformedOut";
            this.lblTransformedOut.Size = new System.Drawing.Size(118, 13);
            this.lblTransformedOut.TabIndex = 7;
            this.lblTransformedOut.Text = "Transformed output file:";
            this.lblTransformedOut.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // txtTransformedOut
            // 
            this.txtTransformedOut.Location = new System.Drawing.Point(142, 86);
            this.txtTransformedOut.Name = "txtTransformedOut";
            this.txtTransformedOut.Size = new System.Drawing.Size(300, 20);
            this.txtTransformedOut.TabIndex = 6;
            // 
            // btnSave
            // 
            this.btnSave.Location = new System.Drawing.Point(320, 114);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(75, 23);
            this.btnSave.TabIndex = 9;
            this.btnSave.Text = "Save";
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // btnClose
            // 
            this.btnClose.Location = new System.Drawing.Point(401, 114);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(75, 23);
            this.btnClose.TabIndex = 9;
            this.btnClose.Text = "Close";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // btnReset
            // 
            this.btnReset.Location = new System.Drawing.Point(239, 114);
            this.btnReset.Name = "btnReset";
            this.btnReset.Size = new System.Drawing.Size(75, 23);
            this.btnReset.TabIndex = 10;
            this.btnReset.Text = "Reset";
            this.btnReset.UseVisualStyleBackColor = true;
            this.btnReset.Click += new System.EventHandler(this.btnReset_Click);
            // 
            // frmDoTransform
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(485, 144);
            this.Controls.Add(this.btnReset);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.btnTransformedOut);
            this.Controls.Add(this.lblTransformedOut);
            this.Controls.Add(this.txtTransformedOut);
            this.Controls.Add(this.btnXslIn);
            this.Controls.Add(this.lblXslIn);
            this.Controls.Add(this.txtXslIn);
            this.Controls.Add(this.btnXmlIn);
            this.Controls.Add(this.lblXmlIn);
            this.Controls.Add(this.txtXmlIn);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "frmDoTransform";
            this.Text = "Transform XML";
            this.Load += new System.EventHandler(this.frmDoTransform_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openXmlFile;
        private System.Windows.Forms.OpenFileDialog openXslFile;
        private System.Windows.Forms.SaveFileDialog saveTransformedFile;
        private System.Windows.Forms.TextBox txtXmlIn;
        private System.Windows.Forms.Label lblXmlIn;
        private System.Windows.Forms.Button btnXmlIn;
        private System.Windows.Forms.Button btnXslIn;
        private System.Windows.Forms.Label lblXslIn;
        private System.Windows.Forms.TextBox txtXslIn;
        private System.Windows.Forms.Button btnTransformedOut;
        private System.Windows.Forms.Label lblTransformedOut;
        private System.Windows.Forms.TextBox txtTransformedOut;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.Button btnReset;
    }
}

